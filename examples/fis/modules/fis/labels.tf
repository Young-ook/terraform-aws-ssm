resource "random_string" "fis-suffix" {
  length  = 12
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  name = var.name == null ? join("-", ["fis", random_string.fis-suffix.result]) : var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
