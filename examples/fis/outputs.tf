locals {
  vclient = join("\n", ["",
    "#!/bin/bash",
    "while true; do",
    "  curl -I http://${aws_lb.alb.dns_name}",
    "  echo",
    "  sleep .1",
    "done",
    ]
  )
}

output "vclient" {
  description = "Script to call APIs as a virtual client"
  value       = local.vclient
}

resource "local_file" "cwagent" {
  content = templatefile("${path.module}/templates/cwagent.tpl", {
    region = var.aws_region
  })
  filename        = "${path.module}/cwagent.sh"
  file_permission = "0600"
}
