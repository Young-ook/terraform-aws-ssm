name = "ssm-bastion-tc2-isolated"
tags = {
  env  = "dev"
  test = "tc2"
}
aws_region = "ap-northeast-2"
vpc_config = {
  cidr        = "10.1.0.0/16"
  azs         = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  subnet_type = "isolated"
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
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 1
    desired_size  = 1
    instance_type = "t3.small"
  }
]
