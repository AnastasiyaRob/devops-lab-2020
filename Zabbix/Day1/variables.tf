variable "zabbix_name" {}
variable "agent_name" {}
variable "machine_type" {}
variable "zone" {}
variable "region"{}
variable "zabbix_tags" {
    type = list
}
variable "agent_tags" {
    type = list
}
variable "image"{}
variable "size" {
    type = number
}
variable "disk_type"{}
variable "zabbix_script" {}
variable "agent_script" {}
variable "network" {}
