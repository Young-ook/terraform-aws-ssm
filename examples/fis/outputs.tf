locals {
  vclient = join("\n", ["",
    "#!/bin/bash",
    "while true; do",
    "  curl -I http://${aws_lb.alb.dns_name}",
    "  echo",
    "  sleep 1",
    "done",
    ]
  )
}

output "vclient" {
  description = "Script to call APIs as a virtual client"
  value       = local.vclient
}
