#!/bin/bash
setenforce 0
systemctl stop firewalld 
sudo yum install -y -q mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl start mariadb
mysql -uroot 
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabpassword';
quit;
yum install -q -y centos-release-scl
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
yum install -q -y zabbix-web-mysql-scl zabbix-apache-conf-scl zabbix-server-mysql zabbix-agent --enablerepo=zabbix-frontend
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uroot zabbix
sed -i '/Europe/s/;//' /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sed -i '/Riga/s/Riga/Minsk/' /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
cat > /etc/zabbix/zabbix_server.conf <<EOF
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=zabpassword
LogType = system
EOF
cat > /etc/zabbix/web/zabbix.conf.php <<EOF
<?php
// Zabbix GUI configuration file.
\$DB['TYPE']                             = 'MYSQL';
\$DB['SERVER']                   = 'localhost';
\$DB['PORT']                             = '0';
\$DB['DATABASE']                 = 'zabbix';
\$DB['USER']                             = 'zabbix';
\$DB['PASSWORD']                 = 'zabpassword';
// Schema name. Used for PostgreSQL.
\$DB['SCHEMA']                   = '';
// Used for TLS connection.
\$DB['ENCRYPTION']               = false;
\$DB['KEY_FILE']                 = '';
\$DB['CERT_FILE']                = '';
\$DB['CA_FILE']                  = '';
\$DB['VERIFY_HOST']              = false;
\$DB['CIPHER_LIST']              = '';
// Use IEEE754 compatible value range for 64-bit Numeric (float) history values.
// This option is enabled by default for new Zabbix installations.
// For upgraded installations, please read database upgrade notes before enabling this option.
\$DB['DOUBLE_IEEE754']   = true;
\$ZBX_SERVER                             = 'localhost';
\$ZBX_SERVER_PORT                = '10051';
\$ZBX_SERVER_NAME                = 'Zabbix Server';
\$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;
EOF
systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm&
