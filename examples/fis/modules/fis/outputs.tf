resource "local_file" "cpu-stress" {
  content = templatefile("${path.module}/templates/cpu-stress.tpl", {
    region = var.region
    alarm      = aws_cloudwatch_metric_alarm.unsteady.arn
    role       = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/cpu-stress.json"
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
    alarm = aws_cloudwatch_metric_alarm.unsteady.arn
    role  = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/terminate-instances.json"
  file_permission = "0600"
}

resource "local_file" "experiments" {
  content = join("\n", [
    "#!/bin/bash -ex",
    "aws fis create-experiment-template --cli-input-json file://cpu-stress.json",
    "aws fis create-experiment-template --cli-input-json file://terminate-instances.json",
    ]
  )
  filename        = "${path.cwd}/fis-create-experiments.sh"
  file_permission = "0700"
}
