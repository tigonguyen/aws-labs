variable "env" {
  type        = string
  description = "(Required) Environment tagging"
}

variable "vpcID" {
  type = string
  description = "(Required) ID for the VPC"
}

variable "subnets" {
  description = "(Required) List of private subnets"
}

variable "albTargetGroup1ARN" {
  description = "(Required) ARN of Load Balancer Target Group 1"
}

variable "albTargetGroup2ARN" {
  description = "(Required) ARN of Load Balancer Target Group 2 (For Blue/Green)"
}

variable "containerPort" {
  description = "(Required) Container exposed port"
}

variable "imageURI" {
  description = "(Required) ECR image URI"
}