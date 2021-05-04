# output variables 

output "asg" {
  description = "The EC2 autoscaling group attributes"
  value       = aws_autoscaling_group.asg
}

output "role" {
  description = "The attribute of IAM role for EC2 autoscaling group"
  value       = aws_iam_role.asg
}
