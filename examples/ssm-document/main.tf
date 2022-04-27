# AWS Systems Manager Document example

terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.71"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# default vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.1"
  name    = var.name
  tags    = var.tags
}

# ec2
module "ec2" {
  source      = "../../"
  name        = var.name
  tags        = var.tags
  subnets     = values(module.vpc.subnets["public"])
  policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  node_groups = var.node_groups
}

# ssm/document
resource "aws_ssm_document" "diskfull" {
  name            = "Run-Disk-Stress"
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/diskfull.yaml")
}

resource "aws_ssm_document" "cwagent" {
  name            = "Install-CloudWatch-Agent"
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/cwagent.yaml")
}

resource "aws_ssm_association" "cwagent" {
  depends_on = [module.ec2]
  name       = aws_ssm_document.cwagent.name

  targets {
    key    = "tag:env"
    values = ["dev"]
  }
}

resource "time_sleep" "wait" {
  depends_on      = [aws_ssm_association.cwagent]
  create_duration = "30s"
}

resource "aws_ssm_association" "diskfull" {
  depends_on = [time_sleep.wait]
  name       = aws_ssm_document.diskfull.name

  targets {
    key    = "tag:env"
    values = ["dev"]
  }

  parameters = {
    DurationSeconds = "60"
    Workers         = "4"
    Percent         = "70"
  }
}
