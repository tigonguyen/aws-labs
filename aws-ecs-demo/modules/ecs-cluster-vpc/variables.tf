variable "vpcCIDR" {
  type = string
  description = "(Required) IP range for the VPC"
}

variable "publicSubnets" {
  type = list
  description = "(Required) IP range for the public subnets"
}

variable "privateSubnets" {
  type = list
  description = "(Required) IP range for the public subnets"
}

variable "availabilityZones" {
  type = list
  description = "(Required) List of availability zones"
}

variable "env" {
  type = string
  description = "(Required) Environment tagging"
}