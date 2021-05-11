resource "random_string" "alb-suffix" {
  length  = 12
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  name = var.name == null ? join("-", ["alb", random_string.alb-suffix.result]) : var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
