name = "ssm-arm64"
tags = {
  env = "dev"
}
aws_region = "ap-northeast-2"
node_groups = [
  {
    name          = "arm64"
    desired_size  = 1
    instance_type = "m6g.medium"
    ami_type      = "AL2_ARM_64"
  },
]
