name = "ssm-x86-arm64-tc1"
tags = {
  env = "dev"
}
aws_region = "ap-northeast-2"
node_groups = [
  {
    name          = "x86"
    desired_size  = 1
    instance_type = "t3.small"
    ami_type      = "AL2_x86_64"
  },
  {
    name          = "arm64"
    desired_size  = 1
    instance_type = "m6g.medium"
    ami_type      = "AL2_ARM_64"
  },
]
