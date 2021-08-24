module "current" {
  source  = "Young-ook/spinnaker/aws//modules/aws-partitions"
  version = ">= 2.0"
}

resource "aws_iam_role" "fis-run" {
  name = local.fis_role_name
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("fis.%s", module.current.partition.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fis-run" {
  policy_arn = format("arn:%s:iam::aws:policy/PowerUserAccess", module.current.partition.partition)
  role       = aws_iam_role.fis-run.id
}

### systems manager document for fault injection simulator experiment

resource "aws_ssm_document" "disk-stress" {
  name            = "FIS-Run-Disk-Stress"
  tags            = merge(local.default-tags, var.tags)
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/disk-stress.yaml")
}

### fault injection simulator experiment templates

locals {
  target_vpc           = module.vpc.vpc.id
  target_role          = module.ec2.role.arn
  target_ec2           = module.ec2.cluster.data_plane.node_groups.baseline.name
  stop_condition_alarm = aws_cloudwatch_metric_alarm.cpu.arn
}

resource "local_file" "cpu-stress" {
  content = templatefile("${path.module}/templates/cpu-stress.tpl", {
    asg    = local.target_ec2
    region = var.aws_region
    alarm  = local.stop_condition_alarm
    role   = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/cpu-stress.json"
  file_permission = "0600"
}

resource "local_file" "network-latency" {
  content = templatefile("${path.module}/templates/network-latency.tpl", {
    asg    = local.target_ec2
    region = var.aws_region
    alarm  = local.stop_condition_alarm
    role   = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/network-latency.json"
  file_permission = "0600"
}

# drawing lots for choosing a subnet
resource "random_integer" "az" {
  min = 0
  max = length(var.azs) - 1
}

resource "local_file" "terminate-instances" {
  content = templatefile("${path.module}/templates/terminate-instances.tpl", {
    asg   = local.target_ec2
    az    = var.azs[random_integer.az.result]
    vpc   = local.target_vpc
    alarm = local.stop_condition_alarm
    role  = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/terminate-instances.json"
  file_permission = "0600"
}

resource "local_file" "throttle-ec2-api" {
  content = templatefile("${path.module}/templates/throttle-ec2-api.tpl", {
    asg_role = local.target_role
    alarm    = local.stop_condition_alarm
    role     = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/throttle-ec2-api.json"
  file_permission = "0600"
}

resource "local_file" "disk-stress" {
  content = templatefile("${path.module}/templates/disk-stress.tpl", {
    doc_arn = aws_ssm_document.disk-stress.arn
    region  = var.aws_region
    alarm   = local.stop_condition_alarm
    role    = aws_iam_role.fis-run.arn
  })
  filename        = "${path.module}/disk-stress.json"
  file_permission = "0600"
}

resource "local_file" "create-templates" {
  content = join("\n", [
    "#!/bin/bash -ex",
    "OUTPUT='.fis_cli_result'",
    "TEMPLATES=('cpu-stress.json' 'network-latency.json' 'terminate-instances.json' 'throttle-ec2-api.json' 'disk-stress.json')",
    "for template in $${TEMPLATES[@]}; do",
    "  aws fis create-experiment-template --cli-input-json file://$${template} --output text --query 'experimentTemplate.id' 2>&1 | tee -a $${OUTPUT}",
    "done",
    ]
  )
  filename        = "${path.module}/fis-create-experiment-templates.sh"
  file_permission = "0600"
}

resource "null_resource" "create-templates" {
  depends_on = [
    local_file.cpu-stress,
    local_file.network-latency,
    local_file.throttle-ec2-api,
    local_file.terminate-instances,
    local_file.disk-stress,
    local_file.create-templates,
  ]
  provisioner "local-exec" {
    when    = create
    command = "bash ${path.module}/fis-create-experiment-templates.sh"
  }
}

resource "local_file" "delete-templates" {
  content = join("\n", [
    "#!/bin/bash -ex",
    "OUTPUT='.fis_cli_result'",
    "while read id; do",
    "  aws fis delete-experiment-template --id $${id} --output text --query 'experimentTemplate.id' 2>&1 > /dev/null",
    "done < $${OUTPUT}",
    "rm $${OUTPUT}",
    ]
  )
  filename        = "${path.module}/fis-delete-experiment-templates.sh"
  file_permission = "0600"
}

resource "null_resource" "delete-templates" {
  depends_on = [
    local_file.cpu-stress,
    local_file.network-latency,
    local_file.throttle-ec2-api,
    local_file.terminate-instances,
    local_file.disk-stress,
    local_file.delete-templates,
  ]

  provisioner "local-exec" {
    when    = destroy
    command = "bash ${path.module}/fis-delete-experiment-templates.sh"
  }
}
