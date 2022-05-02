name = "ssm-x86-wp-arm64-tc3"
tags = {
  env  = "dev"
  test = "warm-pool"
}
aws_region = "ap-northeast-2"
node_groups = [
  {
    name          = "x86"
    desired_size  = 1
    instance_type = "t3.small"
    ami_type      = "AL2_x86_64"
    warm_pool = {
      pool_state                  = "Stopped"
      max_group_prepared_capacity = 2
    }
  },
  {
    name          = "arm64"
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
]
