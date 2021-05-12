# AWS Fault Injection Simulator

terraform {
  required_version = "0.13.5"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source              = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  name                = var.name
  tags                = var.tags
  azs                 = var.azs
  cidr                = var.cidr
  vpc_endpoint_config = var.vpc_endpoint_config
  enable_igw          = var.enable_igw
  enable_ngw          = var.enable_ngw
  single_ngw          = var.single_ngw
}

# ec2
module "ec2" {
  source  = "../../"
  name    = var.name
  tags    = var.tags
  subnets = values(module.vpc.subnets["private"])
  node_groups = [
    {
      name            = "web"
      min_size        = 1
      max_size        = 3
      desired_size    = 3
      instance_type   = "t3.small"
      security_groups = [module.alb.alb_aware_sg]
      user_data       = "#!/bin/bash\namazon-linux-extras install nginx1\nsystemctl start nginx"
    }
  ]
}

# alb
module "alb" {
  source  = "./modules/alb"
  name    = var.name
  tags    = var.tags
  vpc     = module.vpc.vpc.id
  subnets = values(module.vpc.subnets["public"])
  asg     = module.ec2.asg.web.name
}

# fis
module "fis" {
  source = "./modules/fis"
  name   = var.name
  tags   = var.tags
  region = var.aws_region
  azs    = var.azs
  vpc    = module.vpc.vpc.id
  asg    = module.ec2.asg.web.name
  role   = module.ec2.role.arn
}
