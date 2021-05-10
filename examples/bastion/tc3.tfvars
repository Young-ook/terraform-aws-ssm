name = "ssm-tc3-ami"
tags = {
  env  = "dev"
  test = "tc3"
}
aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr       = "10.1.0.0/16"
enable_igw = false
enable_ngw = false
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 1
    desired_size  = 1
    instance_type = "t3.small"
    image_id      = "ami-04a18ed8b7b44aced" # Windows Server 2019 English Full Base (ap-northeast-2)
  }
]
