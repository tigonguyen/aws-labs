generate "provider" {
    path      = "provider.tf"
    if_exists = "overwrite_terragrunt"
    contents  = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {}
}
# Declaration for AWS
provider "aws" {
    region = "ap-southeast-1"
}
EOF
}

# Remote backend settings for all child directories
remote_state {
  backend = "s3"
  config = {
    bucket         = "tigonguyen-ecs-state"
    key            = "${local.env_vars.env}/${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

# Collect values from env_vars.yaml file and set as local variables
locals {
  env_vars = yamldecode(file("envVars.yaml"))
}
