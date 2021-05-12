output "alb" {
  description = "The generated AWS application loadbalancer"
  value       = aws_lb.alb
}

output "alb_aware_sg" {
  description = "The generated AWS security group to allow tls from application loadbalancer"
  value       = aws_security_group.alb_aware.id
}
