#!/bin/bash
sudo yum install -q -y tomcat
sudo systemctl start tomcat
sudo firewall-cmd --permanent --zone=public --add-port=8080
