tomcat_name = "tomcat"
kibana_name = "kibana"
machine_type ="custom-1-4608-ext"
zone = "us-central1-c"
kibana_tags = ["kibana"]
tomcat_tags = ["tomcat"]
image ="centos-cloud/centos-7"
size = "20"
network = "default"
disk_type ="pd-ssd"
kibana_script = "./startup-EK.sh"
tomcat_script =  "./startup-T.sh"
region = "us-central1"
