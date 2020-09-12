#!/bin/bash
sudo yum install -q -y tomcat
sudo systemctl start tomcat
sudo firewall-cmd --permanent --zone=public --add-port=8080/tcp
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/logstash.repo <<EOF
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install -q -y logstash
chmod -R 755 /var/log/tomcat
cat > /etc/logstash/conf.d/my.conf <<EOF
input {
  file {
    path => "/var/log/tomcat/*"
    start_position => "beginning"
  }
}
output {
  elasticsearch {
    hosts => ["${server_ip}:9200"]
  }
  stdout { codec => rubydebug }
}
EOF
sudo systemctl start logstash.service