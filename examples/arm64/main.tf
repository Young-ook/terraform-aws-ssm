# AWS Graviton example

terraform {
  required_version = "~> 1.0"
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
}
