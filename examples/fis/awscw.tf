resource "aws_ssm_association" "install-cwagent" {
  depends_on = [module.ec2]
  name       = "AWS-ConfigureAWSPackage"

  targets {
    key    = "tag:release"
    values = ["baseline,canary"]
  }

  parameters = {
    action = "Install"
    name   = "AmazonCloudWatchAgent"
  }
}

resource "time_sleep" "wait" {
  depends_on      = [aws_ssm_association.install-cwagent]
  create_duration = "30s"
}

resource "aws_ssm_association" "start-cwagent" {
  depends_on = [time_sleep.wait]
  name       = "AmazonCloudWatch-ManageAgent"

  targets {
    key    = "tag:release"
    values = ["baseline,canary"]
  }

  parameters = {
    action = "start"
  }
}

### application/monitoring
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name                = local.cw_cpu_alarm_name
  alarm_description         = "This metric monitors ec2 cpu utilization"
  tags                      = merge(local.default-tags, var.tags)
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 3
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 60
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = module.ec2.cluster.data_plane.node_groups.baseline.name
  }
}

resource "aws_cloudwatch_metric_alarm" "api-p90" {
  alarm_name          = local.cw_api_p90_alarm_name
  alarm_description   = "This metric monitors percentile of response latency"
  tags                = merge(local.default-tags, var.tags)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  unit                = "Seconds"
  threshold           = 0.1
  extended_statistic  = "p90"

  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "api-avg" {
  alarm_name          = local.cw_api_avg_alarm_name
  alarm_description   = "This metric monitors average time of response latency"
  tags                = merge(local.default-tags, var.tags)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  unit                = "Seconds"
  statistic           = "Average"
  threshold           = 0.1

