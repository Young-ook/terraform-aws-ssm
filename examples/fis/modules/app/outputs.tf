output "vpc" {
  description = "The generated Amazon VPC"
  value       = module.vpc.vpc
}

output "ec2" {
  description = "The generated AWS EC2 autoscaling group"
  value       = module.ec2.asg
}

output "role" {
  description = "The attribute of IAM role for EC2 autoscaling group"
  value       = module.ec2.role
}

output "alb" {
  description = "The generated AWS application loadbalancer"
  value       = aws_lb.alb
}

output "alarm" {
  description = "Unsteady state alarm to stop fault injection experiment"
  value       = aws_cloudwatch_metric_alarm.cpu
}
