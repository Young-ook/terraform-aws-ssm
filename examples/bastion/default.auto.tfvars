name = "ssm-bastion"
tags = {
  env  = "dev"
}
aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr       = "10.1.0.0/16"
enable_igw = false
enable_ngw = false
node_groups = [
  {
    name          = "default"
    desired_size  = 1
    instance_type = "t3.small"
  }
]