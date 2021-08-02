output "vpc" {
  description = "The generated Amazon VPC"
  value       = module.vpc.vpc
}

output "ec2" {
  description = "The generated AWS EC2 autoscaling group"
  value       = module.ec2.cluster
}
