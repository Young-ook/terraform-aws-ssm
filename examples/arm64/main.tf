# AWS Graviton example

terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# default vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.1"
  name    = var.name
  tags    = var.tags
}

# ec2
module "ec2" {
  source      = "../../"
  name        = var.name
  tags        = var.tags
  subnets     = values(module.vpc.subnets["public"])
  node_groups = var.node_groups
}
