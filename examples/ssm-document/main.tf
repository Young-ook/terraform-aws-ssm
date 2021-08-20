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
}

# ssm/document
resource "aws_ssm_document" "diskfull" {
  name            = "CustomFIS-Run-Disk-Stress"
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/diskfull.yaml")
}
