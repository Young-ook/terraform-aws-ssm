output "ec2" {
  description = "The generated AWS EC2 autoscaling group"
  value       = module.ec2.cluster
}

output "ssm-doc" {
  description = "The generated AWS Systems Manager Documents"
  value = {
    diskfull = aws_ssm_document.diskfull.arn
    cwagent  = aws_ssm_document.cwagent.arn
  }
}

resource "local_file" "ssm-run-command" {
  content = templatefile("${path.module}/templates/ssm-run-command.tpl", {
    region = var.aws_region
  })
  filename        = "${path.module}/ssm-run-command.sh"
  file_permission = "0600"
}
