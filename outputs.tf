# output variables 

output "cluster" {
  description = "The EC2 autoscaling groups attributes"
  value = {
    name = local.name
    data_plane = {
      node_groups = local.node_groups_enabled ? aws_autoscaling_group.ng : null
    }
  }
}

output "role" {
  description = "The attribute of IAM role for EC2 autoscaling groups"
  value = {
    node_groups = aws_iam_role.ng
  }
}

output "features" {
  description = "Features configurations for the EC2 autoscaling groups"
  value = {
    node_groups_enabled = local.node_groups_enabled
  }
}
