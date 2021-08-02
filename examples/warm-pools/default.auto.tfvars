name = "ssm-wp"
tags = {
  env = "prod"
}
aws_region  = "ap-northeast-2"
azs         = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr        = "10.1.0.0/16"
node_groups = []
warm_pools = [
  {
    name                        = "warm-pool"
    min_size                    = 1
    max_size                    = 1
    desired_size                = 1
    instance_type               = "t3.small"
    pool_state                  = "Stopped"
    min_pool_size               = 1
    max_group_prepared_capacity = 5
  }
]