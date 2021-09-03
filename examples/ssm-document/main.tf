# AWS Systems Manager Document example

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# ec2
module "ec2" {
  source      = "../../"
  name        = var.name
  tags        = var.tags
  node_groups = var.node_groups
  policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
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
