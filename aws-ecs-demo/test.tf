terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
  }
}

provider "aws" {}

module "ecsClusterVPC" {
  source = "./modules/ecs-cluster-vpc"

  vpcCIDR = "10.0.0.0/16"
  publicSubnets = ["10.0.1.0/24", "10.0.2.0/24"]
  privateSubnets = ["10.0.3.0/24", "10.0.4.0/24"]
  availabilityZones = ["ap-southeast-1a", "ap-southeast-1b"]
  env = "dev"
}

module "ecsClusterALB" {
  source = "./modules/ecs-cluster-alb"

  env = "dev"
  vpcID = module.ecsClusterVPC.id
  subnets = module.ecsClusterVPC.publicSubnets
}

module "ecsCluster" {
  source = "./modules/ecs-cluster"

  env = "dev"
  vpcID = module.ecsClusterVPC.id
  subnets = module.ecsClusterVPC.privateSubnets
  albTargetGroup1ARN = module.ecsClusterALB.albTargetGroup1ARN
  albTargetGroup2ARN = module.ecsClusterALB.albTargetGroup2ARN
  containerPort = 443
  imageURI = "public.ecr.aws/k2u4r9u5/nginx:v0.1.0"
}