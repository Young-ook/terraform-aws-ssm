### EC2 Blueprint

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

### network/vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  name    = var.name
  tags    = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "public"
    single_ngw  = true
  }
  vpce_config = [
    {
      service             = "ssmmessages"
      type                = "Interface"
      private_dns_enabled = true
    },
    {
      service             = "ssm"
      type                = "Interface"
      private_dns_enabled = true
    },
  ]
}

### network/eip
resource "aws_eip" "eip" {
  vpc  = true
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

### compute
module "ec2" {
  source  = "Young-ook/ssm/aws"
  version = "1.0.5"
  tags    = var.tags
  subnets = values(module.vpc.subnets["public"])
  node_groups = [
    {
      name          = "bastion"
      desired_size  = 1
      instance_type = "t3.medium"
      ami_type      = "AL2_x86_64"
      policy_arns = [
        "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
      ]
    },
    {
      name          = "eip"
      desired_size  = 1
      min_size      = 1
      max_size      = 1
      instance_type = "t3.small"
      tags          = merge({ eipAllocId = aws_eip.eip.id })
      user_data     = file("${path.module}/apps/eip/eip.tpl")
      policy_arns   = [aws_iam_policy.eip.arn]
    },
    {
      name          = "spot"
      desired_size  = 1
      instance_type = "m6g.medium"
      ami_type      = "AL2_ARM_64"
      instances_distribution = {
        on_demand_percentage_above_base_capacity = 50
        spot_allocation_strategy                 = "capacity-optimized"
      }
      instances_override = [
        {
          instance_type     = "m6g.medium"
          weighted_capacity = 2
        },
        {
          instance_type     = "m6g.large"
          weighted_capacity = 1
        }
      ]
    },
    {
      name          = "warmpools"
      desired_size  = 0
      min_size      = 0
      max_size      = 3
      instance_type = "t3.small"
      user_data     = templatefile("${path.module}/apps/warmpools/httpd.tpl", { lc_name = "warmpools-lifecycle-hook-action" })
      policy_arns   = [aws_iam_policy.lc.arn]
      warm_pool = {
        max_group_prepared_capacity = 2
        pool_state                  = "Stopped"
      }
    }
  ]
}

# lifecycle hook complete signal policy
resource "aws_iam_policy" "lc" {
  name = "warmpools-lifecycle-hook-action"
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
  name                   = "warmpools-lifecycle-hook-action"
  autoscaling_group_name = module.ec2.cluster.data_plane.node_groups.warmpools.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 900
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

resource "local_file" "elapsedtime" {
  content = templatefile("${path.module}/apps/warmpools/elapsedtime.tpl", {
    asg_name = module.ec2.cluster.data_plane.node_groups.warmpools.name
    region   = var.aws_region
  })
  filename        = "${path.module}/elapsedtime.sh"
  file_permission = "0500"
}

### security/policy
resource "aws_iam_policy" "eip" {
  name = "eip-auto-reassociation-policy"
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