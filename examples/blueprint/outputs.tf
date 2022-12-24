output "ec2" {
  description = "The generated AWS EC2 autoscaling groups"
  value       = module.ec2.cluster.data_plane
}
