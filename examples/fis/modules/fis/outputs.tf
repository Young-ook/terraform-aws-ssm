resource "local_file" "cpu-stress" {
  content = templatefile("${path.module}/templates/cpu-stress.tpl", {
    region = var.region
    alarm  = var.alarm
    role   = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/cpu-stress.json"
  file_permission = "0600"
}

resource "local_file" "network-latency" {
  content = templatefile("${path.module}/templates/network-latency.tpl", {
    region = var.region
    alarm  = var.alarm
    role   = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/network-latency.json"
  file_permission = "0600"
}

resource "random_integer" "az" {
  min = 0
  max = length(var.azs) - 1
}

resource "local_file" "terminate-instances" {
  content = templatefile("${path.module}/templates/terminate-instances.tpl", {
    az    = var.azs[random_integer.az.result]
    vpc   = var.vpc
    alarm = var.alarm
    role  = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/terminate-instances.json"
  file_permission = "0600"
}

resource "local_file" "throttle-ec2-api" {
  content = templatefile("${path.module}/templates/throttle-ec2-api.tpl", {
    asg_role = var.role
    alarm    = var.alarm
    role     = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/throttle-ec2-api.json"
  file_permission = "0600"
}

resource "local_file" "experiments" {
  content = join("\n", [
    "#!/bin/bash -ex",
    "aws fis create-experiment-template --cli-input-json file://cpu-stress.json",
    "aws fis create-experiment-template --cli-input-json file://network-latency.json",
    "aws fis create-experiment-template --cli-input-json file://terminate-instances.json",
    "aws fis create-experiment-template --cli-input-json file://throttle-ec2-api.json",
    ]
  )
  filename        = "${path.cwd}/fis-create-experiments.sh"
  file_permission = "0700"
}
