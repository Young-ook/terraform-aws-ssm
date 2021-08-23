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
