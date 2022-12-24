terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
}

module "main" {
  source  = "../.."
  subnets = values(module.vpc.subnets["public"])
  node_groups = [
    {
      name          = "al2"
      desired_size  = 1
      instance_type = "t3.small"
      ami_type      = "AL2_x86_64"
    },
    {
      name          = "win"
      desired_size  = 1
      instance_type = "t3.small"
      image_id      = data.aws_ami.win.id
    }
  ]
}

data "aws_ami" "win" {
  most_recent = true

  filter {
    name   = "platform"
    values = ["windows"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "test_assertions" "pet_name" {
  component = "pet_name"

  check "pet_name" {
    description = "default random pet name"
    condition   = can(regexall("^ec2", module.main.cluster.name) == 3)
  }
}
