# EC2 Warm Pools

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "asg" {}

# lifecycle hook complete signal policy
resource "aws_iam_policy" "lc" {
  name = join("-", [random_pet.asg.id, "complete-lifecycle-action"])
  tags = var.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:CompleteLifecycleAction",
        ]
        Effect   = "Allow"
        Resource = [module.ec2.cluster.data_plane.warm_pools.default.arn]
      },
      {
        Action = [
          "autoscaling:DescribeAutoScalingInstances",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })
}

# ec2
module "ec2" {
  source      = "../../"
  name        = random_pet.asg.id
  tags        = var.tags
  policy_arns = [aws_iam_policy.lc.arn]
  warm_pools = [
    {
      name                        = "default"
      desired_size                = 0
      min_size                    = 0
      max_size                    = 3
      instance_type               = "t3.small"
      pool_state                  = "Stopped"
      max_group_prepared_capacity = 2
      user_data                   = templatefile("${path.module}/userdata.tpl", { lc_name = random_pet.asg.id })
    }
  ]
}

resource "aws_autoscaling_lifecycle_hook" "lc" {
  name                   = random_pet.asg.id
  autoscaling_group_name = module.ec2.cluster.data_plane.warm_pools.default.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 900
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

resource "local_file" "elapsedtime" {
  content = templatefile("${path.module}/elapsedtime.tpl", {
    asg_name = module.ec2.cluster.data_plane.warm_pools.default.name,
    region   = var.aws_region
  })
  filename        = "${path.module}/elapsedtime.sh"
  file_permission = "0500"
}
