############ Terragrunt section #############
# Get configuration from root directory
include {
    path = find_in_parent_folders()
}

########### Terraform section ##############
# Use remote module for configuration
terraform {
  source = "../../../modules/ecs-cluster-alb"
}

# Collect values from env_vars.yaml file and set as local variables
locals {
  envVars = yamldecode(file(find_in_parent_folders("envVars.yaml")))
}

# Define dependencies on other modules
dependency "ecsClusterVPC" {
  config_path = "../ecs-cluster-vpc"
}
dependency "ecsClusterALB" {
  config_path = "../ecs-cluster-alb"
}


# Pass data into remote module with inputs
inputs = {
  vpcID = dependency.ecsClusterVPC.outputs.id
  subnets = dependency.ecsClusterVPC.outputs.privateSubnets
  albTargetGroup1ARN = dependency.ecsClusterALB.outputs.albTargetGroup1ARN
  albTargetGroup2ARN = dependency.ecsClusterALB.outputs.albTargetGroup2ARN
  env = local.envVars.env
  imageURI = local.envVars.containerPort
  containerPort = local.envVars.imageURI
}