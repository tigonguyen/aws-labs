############ Terragrunt section #############
# Get configuration from root directory
include {
    path = find_in_parent_folders()
}

########### Terraform section ##############
# Use remote module for configuration
terraform {
  source = "../../../modules/ecs-cluster-vpc"
}

# Collect values from env_vars.yaml file and set as local variables
locals {
  envVars = yamldecode(file(find_in_parent_folders("envVars.yaml")))
}

# Pass data into remote module with inputs
inputs = {
  vpcCIDR = local.envVars.vpcCIDR
  privateSubnets = local.envVars.privateSubnets
  publicSubnets = local.envVars.publicSubnets
  availabilityZones = local.envVars.availabilityZones
  env = local.envVars.env
}