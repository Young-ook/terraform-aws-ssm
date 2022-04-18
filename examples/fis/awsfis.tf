### systems manager document for fault injection simulator experiment

resource "aws_ssm_document" "disk-stress" {
  name            = "FIS-Run-Disk-Stress"
  tags            = merge(local.default-tags, var.tags)
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/disk-stress.yaml")
}

### fault injection simulator experiment templates

# drawing lots for choosing a subnet
resource "random_integer" "az" {
  min = 0
  max = length(var.azs) - 1
}

locals {
  target_vpc  = module.vpc.vpc.id
  target_role = module.ec2.role.arn
  target_asg  = module.ec2.cluster.data_plane.node_groups.baseline.name
  fis_role    = module.awsfis.role.arn

  experiments = [
    {
      name     = "cpu-stress"
      template = "${path.cwd}/templates/cpu-stress.tpl"
      params = {
        asg    = local.target_asg
        region = var.aws_region
        alarm  = aws_cloudwatch_metric_alarm.cpu.arn
        role   = local.fis_role
      }
    },
    {
      name     = "network-latency"
      template = "${path.cwd}/templates/network-latency.tpl"
      params = {
        asg    = local.target_asg
        region = var.aws_region
        alarm  = aws_cloudwatch_metric_alarm.cpu.arn
        role   = local.fis_role
      }
    },
    {
      name     = "terminate-instances"
      template = "${path.cwd}/templates/terminate-instances.tpl"
      params = {
        asg   = local.target_asg
        az    = var.azs[random_integer.az.result]
        vpc   = local.target_vpc
        alarm = aws_cloudwatch_metric_alarm.cpu.arn
        role  = local.fis_role
      }
    },
    {
      name     = "throttle-ec2-api"
      template = "${path.cwd}/templates/throttle-ec2-api.tpl"
      params = {
        asg_role = local.target_role
        alarm    = aws_cloudwatch_metric_alarm.cpu.arn
        role     = local.fis_role
      }
    },
    {
      name     = "disk-stress"
      template = "${path.cwd}/templates/disk-stress.tpl"
      params = {
        doc_arn = aws_ssm_document.disk-stress.arn
        region  = var.aws_region
        alarm   = aws_cloudwatch_metric_alarm.cpu.arn
        role    = local.fis_role
      }
    },
  ]
}

module "awsfis" {
  source      = "Young-ook/fis/aws"
  name        = var.name
  tags        = var.tags
  experiments = local.experiments
}
