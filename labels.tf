resource "random_string" "uid" {
  length  = 12
  upper   = false
  lower   = true
  number  = false
  special = false
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  service = "ec2"
  uid     = join("-", [local.service, random_string.uid.result])
  name    = var.name == null ? local.uid : join("-", [var.name, random_string.suffix.result])
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
