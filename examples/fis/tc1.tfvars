name = "ssm-fis-tc1"
tags = {
  env  = "prod"
  test = "tc1"
}
aws_region          = "ap-northeast-2"
azs                 = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr                = "10.1.0.0/16"
vpc_endpoint_config = []
enable_igw          = true
enable_ngw          = true
single_ngw          = true
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 3
    instance_type = "t3.small"
    user_data     = "#!/bin/bash\nyum update -y\nyum install -y httpd\nsystemctl start httpd\nsystemctl enable httpd"
  }
]
