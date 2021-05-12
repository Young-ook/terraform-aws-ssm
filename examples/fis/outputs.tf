output "vpc" {
  description = "The generated Amazon VPC"
  value       = module.app.vpc
}

output "ec2" {
  description = "The generated AWS EC2 autoscaling group"
  value       = module.app.ec2
}

output "alb" {
  description = "The generated AWS application loadbalancer"
  value       = module.app.alb
}
