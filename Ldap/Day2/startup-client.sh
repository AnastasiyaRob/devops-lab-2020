#!/bin/bash
sudo yum -y -q install openldap-clients nss-pam-ldapd
sudo systemctl stop firewalld
sudo authconfig --enableldap \
--enableldapauth \
--ldapserver=${server_ip} \
--ldapbasedn="dc=devopsldab,dc=com" \
--enablemkhomedir \
--update
sudo systemctl restart nslcd
cat >/opt/ssh_ldap.sh <<EOF
#!/bin/bash
set -eou pipefail
IFS=$'\n\t'

result=\$(ldapsearch -x '(&(objectClass=posixAccount)(uid='"\$1"'))' 'sshPublicKey')
attrLine=\$(echo "\$result" | sed -n '/^ /{H;d};/sshPublicKey:/x;\$g;s/\n *//g;/sshPublicKey:/p')

if [[ "\$attrLine" == sshPublicKey::* ]]; then
  echo "$\attrLine" | sed 's/sshPublicKey:: //' | base64 -d
elif [[ "\$attrLine" == sshPublicKey:* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey: //'
else
  exit 1
fi
EOF
sudo chmod 755 /opt/ssh_ldap.sh
sed -i -e '/AuthorizedKeysCommand no/s!#!!'  /etc/ssh/sshd_config
sed -i -e '/nobody/s!#!!'  /etc/ssh/sshd_config
sed -i -e '/AuthorizedKeysCommand no/s!none!/opt/ssh_ldap.sh!'  /etc/ssh/sshd_config
sed -i -e '/PasswordAuthentication yes/s!yes!no!'  /etc/ssh/sshd_config
sudo systemctl restart sshd

