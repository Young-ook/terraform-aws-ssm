### integrated development environment
resource "aws_cloud9_environment_ec2" "ide" {
  name                        = local.name
  tags                        = merge(local.default-tags, var.tags)
  instance_type               = lookup(var.workspace, "instance_type", local.default_workspace.instance_type)
  automatic_stop_time_minutes = lookup(var.workspace, "automatic_stop_time_minutes", local.default_workspace.automatic_stop_time_minutes)
  connection_type             = lookup(var.workspace, "connection_type", local.default_workspace.connection_type)
  subnet_id                   = var.subnet
}

data "aws_instance" "ide" {
  filter {
    name   = "tag:aws:cloud9:environment"
    values = [aws_cloud9_environment_ec2.ide.id]
  }
}
