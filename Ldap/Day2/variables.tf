variable "client_name" {}
variable "server_name" {}
variable "machine_type" {}
variable "zone" {}
variable "region"{}
variable "client_tags" {
    type = list
}
variable "server_tags" {
    type = list
}
variable "image"{}
variable "size" {
    type = number
}
variable "disk_type"{}
variable "server_script" {}
variable "network" {}
