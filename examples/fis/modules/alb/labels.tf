resource "random_string" "uid" {
  length  = 12
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  service           = "alb"
  uid               = join("-", [local.service, random_string.uid.result])
  name              = var.name == null || var.name == "" ? local.uid : var.name
  alb_sg_name       = join("-", [local.name, "alb"])
  alb_aware_sg_name = join("-", [local.name, "alb-aware"])
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
