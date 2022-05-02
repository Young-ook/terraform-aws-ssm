name        = "ssm-bastion"
tags        = {}
aws_region  = "ap-northeast-2"
vpc_config  = {}
vpce_config = []
node_groups = [
  {
    name          = "default"
    desired_size  = 1
    instance_type = "t3.small"
  }
]
