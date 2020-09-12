#!/bin/bash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat > /etc/yum.repos.d/elasticsearch.repo <<EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
sudo yum install -q -y --enablerepo=elasticsearch elasticsearch
cat >/etc/yum.repos.d/kibana.repo <<EOF
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install -q -y kibana
sed -i '/elasticsearch.host/s/#//' /etc/kibana/kibana.yml
sed -i '/server.host/s/localhost/0.0.0.0/' /etc/kibana/kibana.yml
sed -i '/server.host:/s/#//' /etc/kibana/kibana.yml
sed -i '/server.port/s/#//' /etc/kibana/kibana.yml
sudo systemctl start kibana.service
sudo firewall-cmd --permanent --zone=public --add-port=5601/tcp
sudo firewall-cmd --permanent --zone=public --add-port=9200/tcp
sudo firewall-cmd --reload
cat >> /etc/elasticsearch/elasticsearch.yml <<EOF
network.host: 0.0.0.0
transport.host: localhost
http.port: 9200
discovery.seed_hosts: ["0.0.0.0", "*"]
EOF
sudo systemctl start elasticsearch.service

