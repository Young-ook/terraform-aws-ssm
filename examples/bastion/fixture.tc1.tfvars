name = "ssm-bastion-tc1-private"
tags = {
  env  = "dev"
  test = "tc1"
}
aws_region = "ap-northeast-2"
vpc_config = {
  cidr        = "10.1.0.0/16"
  azs         = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  single_ngw  = true
  subnet_type = "private"
}
vpce_config = []
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 1
    desired_size  = 1
    instance_type = "t3.small"
  }
]
