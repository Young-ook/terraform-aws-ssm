# AWS Fault Injection Simulator

terraform {
  required_version = "0.13.5"
}

provider "aws" {
  region = var.aws_region
}

# app
module "app" {
  source = "./modules/app"
  name   = var.name
  tags   = var.tags
  azs    = var.azs
  cidr   = var.cidr
}

# fis
module "fis" {
  source = "./modules/fis"
  name   = var.name
  tags   = var.tags
  region = var.aws_region
  azs    = var.azs
  vpc    = module.app.vpc.id
  alarm  = module.app.alarm["cpu"].arn
  role   = module.app.role.arn
}
