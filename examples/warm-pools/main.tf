# bastion host using AWS session manager example

terraform {
  required_version = "0.15.5"
}

provider "aws" {
  region = var.aws_region
}

# ec2
module "ec2" {
  source      = "../../"
  name        = var.name
  tags        = var.tags
  node_groups = var.node_groups
  warm_pools  = var.warm_pools
}
