# EC2 Warm Pools

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

resource "random_pet" "wp" {}

# default vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.1"
  name    = random_pet.wp.id
  tags    = var.tags
}

# ec2
module "ec2" {
  source  = "../../"
  name    = random_pet.wp.id
  tags    = var.tags
  subnets = values(module.vpc.subnets["public"])
  node_groups = [
    {
      name          = "default"
      desired_size  = 0
      min_size      = 0
      max_size      = 3
      instance_type = "t3.small"
      user_data     = templatefile("${path.module}/userdata.tpl", { lc_name = random_pet.wp.id })
      policy_arns   = [aws_iam_policy.lc.arn]
      warm_pool = {
        pool_state                  = "Stopped"
        max_group_prepared_capacity = 2
      }
    }
  ]
}

# lifecycle hook complete signal policy
resource "aws_iam_policy" "lc" {
  name = join("-", [random_pet.wp.id, "lc-action"])
  tags = var.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:DescribeAutoScalingInstances",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_autoscaling_lifecycle_hook" "lc" {
  name                   = random_pet.wp.id
  autoscaling_group_name = module.ec2.cluster.data_plane.node_groups.default.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 900
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

resource "local_file" "elapsedtime" {
  content = templatefile("${path.module}/elapsedtime.tpl", {
    asg_name = module.ec2.cluster.data_plane.node_groups.default.name
    region   = var.aws_region
  })
  filename        = "${path.module}/elapsedtime.sh"
  file_permission = "0500"
}
