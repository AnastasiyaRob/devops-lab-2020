variable "kibana_name" {}
variable "tomcat_name" {}
variable "machine_type" {}
variable "zone" {}
variable "region"{}
variable "kibana_tags" {
    type = list
}
variable "tomcat_tags" {
    type = list
}
variable "image"{}
variable "size" {
    type = number
}
variable "disk_type"{}
variable "kibana_script" {}
variable "tomcat_script" {}
variable "network" {}
