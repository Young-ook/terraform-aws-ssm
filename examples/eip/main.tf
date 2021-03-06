# bastion host using EIP

terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.71"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# eip
resource "aws_eip" "eip" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

# describe tags policy
resource "aws_iam_policy" "eip" {
  name = join("-", [var.name, "describe-tags"])
  tags = var.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "ec2:DescribeTags",
        "ec2:AssociateAddress",
      ]
      Effect   = "Allow"
      Resource = ["*"]
    }, ]
  })
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
  source  = "../../"
  name    = var.name
  tags    = merge(var.tags, { eipAllocId = aws_eip.eip.id })
  subnets = values(module.vpc.subnets["public"])
  node_groups = [
    {
      name          = "gateway"
      desired_size  = 1
      min_size      = 1
      max_size      = 1
      instance_type = "t3.small"
      user_data     = file("${path.module}/userdata.tpl")
      policy_arns   = [aws_iam_policy.eip.arn]
    }
  ]
}
