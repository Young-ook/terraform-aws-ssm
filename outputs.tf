# output variables 

output "asg" {
  description = "The EC2 autoscaling group attributes"
  value       = aws_autoscaling_group.asg
}

