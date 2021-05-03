resource "random_string" "asg-suffix" {
  length  = 12
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  name = var.name == null ? join("-", ["asg", random_string.asg-suffix.result]) : var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
