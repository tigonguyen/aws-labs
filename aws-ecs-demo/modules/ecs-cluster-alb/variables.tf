variable "vpcID" {
  type        = string
  description = "(Required) ID for the VPC"
}

variable "subnets" {
  type = list
  description = "(Required) List of private subnets"
}

variable "env" {
  type        = string
  description = "(Required) Environment tagging"
}