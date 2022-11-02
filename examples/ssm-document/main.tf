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

### network/vpc (default vpc)
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.1"
  name    = var.name
  tags    = var.tags
}

### ec2
module "ec2" {
  source  = "Young-ook/ssm/aws"
  version = "1.0.3"
  name    = var.name
  tags    = var.tags
  subnets = values(module.vpc.subnets["public"])
  node_groups = [
    {
      name          = "default"
      tags          = merge(var.tags, { envoy = "enabled" })
      desired_size  = 1
      instance_type = "t3.small"
      ami_type      = "AL2_x86_64"
      user_data     = local.server
      policy_arns = [
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
    },
  ]
}

### application/script
locals {
  server = join("\n", [
    "sudo yum update -y",
    "sudo yum install -y httpd",
    "sudo rm /etc/httpd/conf.d/welcome.conf",
    "sudo systemctl start httpd",
    ]
  )
}

### management/document (playbook)
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

resource "aws_ssm_document" "envoy" {
  name            = "Install-EnvoyProxy"
  document_format = "YAML"
  document_type   = "Command"
  content         = file(join("/", [path.module, "templates", "envoy.yaml"]))
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
  create_duration = "15s"
}

resource "aws_ssm_association" "diskfull" {
  depends_on = [time_sleep.wait]
  name       = aws_ssm_document.diskfull.name
  parameters = {
    DurationSeconds = "60"
    Workers         = "4"
    Percent         = "70"
  }
  targets {
    key    = "tag:env"
    values = ["dev"]
  }
}

resource "aws_ssm_association" "envoy" {
  depends_on       = [time_sleep.wait]
  name             = aws_ssm_document.envoy.name
  association_name = "Install-Envoy"
  parameters = {
    region       = var.aws_region
    mesh         = "app"
    vnode        = "service"
    envoyVersion = "v1.23.1.0"
    appPort      = "80"
  }
  targets {
    key    = "tag:envoy"
    values = ["enabled"]
  }
}
