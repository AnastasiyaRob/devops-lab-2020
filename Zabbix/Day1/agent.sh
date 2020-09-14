#!/bin/bash
sudo yum install -q -y centos-release-scl
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum install -q -y zabbix-agent
sudo systemctl start zabbix-agent&

