### default values

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  default_ec2 = {
    keypair         = null
    instance_type   = "t3.medium"
    volume_size     = "20"
    volume_type     = "gp2"
    security_groups = []
  }
  default_asg = {
    desired_size      = 1
    min_size          = 1
    max_size          = 3
    target_group_arns = null
  }
}
