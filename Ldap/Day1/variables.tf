variable "name" {}
variable "machine_type" {}
variable "zone" {}
variable "tags" {
    type = list
}
variable "image"{}
variable "size" {
    type = number
}
variable "disk_type"{}
variable "script" {}
variable "network" {}

