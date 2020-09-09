#!/bin/bash
sudo yum -y -q install openldap openldap-servers openldap-clients
sudo systemctl start slapd
sudo systemctl enable slapd
sudo firewall-cmd --add-service=ldap
sudo firewall-cmd --add-service=http
sudo systemctl stop firewalld 
echo "export passwdhash=`slappasswd -s test` " >> ~/.bashrc
echo "export passwd=test" >> ~/.bashrc
source ~/.bashrc
###############################################
cat >ldaprootpasswd.ldif  <<EOF 
echo 'dn: olcDatabase={0}config,cn=config'
echo 'changetype: modify'
echo 'add: olcRootPW'
echo 'olcRootPW: $passwdhash'
EOF
##############################################
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f ldaprootpasswd.ldif
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown -R ldap:ldap /var/lib/ldap/DB_CONFIG
sudo systemctl restart slapd
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
##############################################
cat >ldapdomain.ldif <<EOF
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=Manager,dc=devopsldab,dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=devopsldab,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=devopsldab,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $passwdhash

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=devopsldab,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=devopsldab,dc=com" write by * read
EOF
##############################################
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f ldapdomain.ldif
##############################################
cat >publickey.ldif <<EOF
dn: cn=openssh-lpk,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: openssh-lpk
olcAttributeTypes: ( 1.3.6.1.4.1.24552.500.1.1.1.13 NAME 'sshPublicKey'
    DESC 'MANDATORY: OpenSSH Public key'
    EQUALITY octetStringMatch
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )
olcObjectClasses: ( 1.3.6.1.4.1.24552.500.1.1.2.0 NAME 'ldapPublicKey' SUP top AUXILIARY
    DESC 'MANDATORY: OpenSSH LPK objectclass'
    MAY ( sshPublicKey $ uid )
    )
EOF
##############################################
ldapadd -Y EXTERNAL -H ldapi:/// -f publickey.ldif
##############################################
cat >baseldapdomain.ldif <<EOF
dn: dc=devopsldab,dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: devopsldab com
dc: devopsldab

dn: cn=Manager,dc=devopsldab,dc=com
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=devopsldab,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=devopsldab,dc=com
objectClass: organizationalUnit
ou: Group
EOF
#############################################
sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w $passwd -f baseldapdomain.ldif 
##############################################
cat >ldapgroup.ldif <<EOF
dn: cn=Manager,ou=Group,dc=devopsldab,dc=com
objectClass: top
objectClass: posixGroup
gidNumber: 1005
EOF
##############################################
sudo ldapadd -x -w $passwd -D "cn=Manager,dc=devopsldab,dc=com" -f ldapgroup.ldif 
#############################################
cat >ldapuser.ldif <<EOF
dn: uid=my_user,ou=People,dc=devopsldab,dc=com
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
objectClass: ldapPublicKey
cn: my_user
uid: my_user
uidNumber: 1005
gidNumber: 1005
homeDirectory: /home/my_user
userPassword: $passwdhash
loginShell: /bin/bash
gecos: my_user
shadowLastChange: 0
shadowMax: -1
shadowWarning: 0
sshPublicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDskN+/ecJGWOqf5Eq+dljb8XfwYfb545OV3/H1Yqi1CNg4coRBYRaX6/9vPxxCQFTTtjMjQf27aDeDsahEjXktkQT27H1/WSMiy4oakrfMogEtl98Kg4z8yCPR2K+we/hrRGsOqxWQRriCtElfaf7wxvlosanqT/SNlgsGqTyQtAkrbGame4kEgVjOeTSwSCSzcTCxbRrgYbfBNlC971i3nyve9oNt5A1PlLK0xnkypA8q+sz7al811H3g4m2ZzlKhecmRMf4M7uWEURrkayggMIJYIrNcICXjzMvJXPf336a4zaQWfHIyFf5bm7RpkZerBpDhUfiUlI4wlTASIld3 root@CentOS
EOF
##############################################
ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w $passwd -f ldapuser.ldif
##############################################
sudo yum -y -q install epel-release
sudo yum --enablerepo=epel -y -q install phpldapadmin
sed -i -e '397s!//!!' /etc/phpldapadmin/config.php
sed -i -e '398s!^!//!' /etc/phpldapadmin/config.php
sed -i -e '/local/s!local!all granted!' /etc/httpd/conf.d/phpldapadmin.conf
sudo systemctl start httpd
unset passwdhash
unset passwd
rm -rf *.ldif
   
