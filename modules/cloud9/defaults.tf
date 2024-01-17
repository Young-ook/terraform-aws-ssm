### default values

module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  default_workspace = {
    instance_type               = "t2.micro"
    connection_type             = "CONNECT_SSM" # allowed values: CONNECT_SSH, CONNECT_SSM
    automatic_stop_time_minutes = 30
  }
}
