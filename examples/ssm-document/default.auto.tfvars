name = "ssm-doc"
tags = {
  env = "dev"
}
aws_region = "ap-northeast-2"
node_groups = [
  {
    name          = "default"
    desired_size  = 1
    instance_type = "t3.small"
    ami_type      = "AL2_x86_64"
  },
]
