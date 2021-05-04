resource "random_string" "ec2-suffix" {
  length  = 12
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  name = var.name == null ? join("-", ["ec2", random_string.ec2-suffix.result]) : var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
