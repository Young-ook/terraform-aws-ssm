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

output "vclient" {
  description = "Script to call APIs as a virtual client"
  value = join("\n", [
    "#!/bin/bash",
    "while true; do",
    "  curl -I http://${module.app.alb.dns_name}",
    "  echo",
    "  sleep .5",
    "done",
    ]
  )
}
