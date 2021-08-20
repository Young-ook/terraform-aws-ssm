# bastion host using AWS session manager example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# isolated vpc
module "vpc" {
  source     = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  name       = var.name
  tags       = var.tags
  azs        = var.azs
  cidr       = var.cidr
  enable_igw = var.enable_igw
  enable_ngw = var.enable_ngw
  single_ngw = var.single_ngw
}

# ec2
module "ec2" {
  source      = "../../"
  name        = var.name
  tags        = var.tags
  subnets     = values(module.vpc.subnets["private"])
  node_groups = var.node_groups
}
