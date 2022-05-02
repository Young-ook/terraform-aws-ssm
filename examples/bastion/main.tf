# bastion host using AWS session manager example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source      = "Young-ook/vpc/aws"
  version     = "1.0.1"
  name        = var.name
  tags        = var.tags
  vpc_config  = var.vpc_config
  vpce_config = var.vpce_config
}

locals {
  default_vpc = var.vpc_config == null || var.vpc_config == {} ? true : false
}

# ec2
module "ec2" {
  source      = "../../"
  name        = var.name
  tags        = var.tags
  subnets     = values(module.vpc.subnets[local.default_vpc ? "public" : "private"])
  node_groups = var.node_groups
}
