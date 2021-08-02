output "ec2" {
  description = "The generated AWS EC2 autoscaling groups"
  value       = module.ec2.cluster
}

output "role" {
  description = "The generated IAM Role for AWS EC2 autoscaling group "
  value       = module.ec2.role
}
