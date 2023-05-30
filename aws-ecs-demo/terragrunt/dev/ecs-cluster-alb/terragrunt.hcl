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

# Pass data into remote module with inputs
inputs = {
  vpcID = dependency.ecsClusterVPC.outputs.id
  subnets = dependency.ecsClusterVPC.outputs.publicSubnets
  env = local.envVars.env
}