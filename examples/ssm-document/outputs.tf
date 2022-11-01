output "ec2" {
  description = "The generated AWS EC2 autoscaling group"
  value       = module.ec2.cluster
}

output "ssm-doc" {
  description = "The generated AWS Systems Manager Documents"
  value = {
    diskfull = aws_ssm_document.diskfull.arn
    cwagent  = aws_ssm_document.cwagent.arn
    envoy    = aws_ssm_document.envoy.arn
  }
}
