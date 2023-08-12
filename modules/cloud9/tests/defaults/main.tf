terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.5"
}

module "main" {
  source = "../.."
  subnet = values(module.vpc.subnets["public"])[0]
}
