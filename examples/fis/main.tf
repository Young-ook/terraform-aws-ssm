# AWS Fault Injection Simulator

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

### foundation/network
module "vpc" {
  source              = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  name                = var.name
  tags                = var.tags
  azs                 = var.azs
  cidr                = var.cidr
  enable_igw          = true
  enable_ngw          = true
  single_ngw          = true
  vpc_endpoint_config = []
}

resource "aws_lb" "alb" {
  name                       = local.alb_name
  tags                       = merge(local.default-tags, var.tags)
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = values(module.vpc.subnets["private"])
  enable_deletion_protection = false
}

# security/firewall
resource "aws_security_group" "alb" {
  name        = local.alb_sg_name
  description = format("security group for %s", local.alb_sg_name)
  tags        = merge({ "Name" = local.alb_sg_name }, local.default-tags, var.tags)
  vpc_id      = module.vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_aware" {
  name        = local.alb_aware_sg_name
  description = format("security group for %s", local.alb_aware_sg_name)
  tags        = merge({ "Name" = local.alb_aware_sg_name }, local.default-tags, var.tags)
  vpc_id      = module.vpc.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  depends_on                    = [aws_lb.alb]
  name                          = join("-", [local.alb_name, "http"])
  tags                          = merge(local.default-tags, var.tags)
  vpc_id                        = module.vpc.vpc.id
  port                          = 80
  protocol                      = "HTTP"
  target_type                   = "instance"
  load_balancing_algorithm_type = "least_outstanding_requests"
  deregistration_delay          = 10

  health_check {
    enabled  = true
    interval = 30
    path     = "/"
    port     = "traffic-port"
    protocol = "HTTP"
  }
}

### application/ec2
module "ec2" {
  source      = "Young-ook/ssm/aws"
  name        = var.name
  tags        = var.tags
  policy_arns = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  node_groups = [
    {
      name              = "baseline"
      min_size          = 2
      max_size          = 6
      desired_size      = 2
      instance_type     = "t3.small"
      security_groups   = [aws_security_group.alb_aware.id]
      target_group_arns = [aws_lb_target_group.http.arn]
      tags              = { release = "baseline" }
      user_data         = "#!/bin/bash\namazon-linux-extras install nginx1\nsystemctl start nginx"
    },
    {
      name              = "canary"
      min_size          = 1
      max_size          = 1
      desired_size      = 1
      instance_type     = "t3.small"
      security_groups   = [aws_security_group.alb_aware.id]
      target_group_arns = [aws_lb_target_group.http.arn]
      tags              = { release = "canary" }
      user_data         = "#!/bin/bash\namazon-linux-extras install nginx1\nsystemctl start nginx"
    },
    {
      name              = "loadgen"
      min_size          = 1
      max_size          = 1
      desired_size      = 1
      instance_type     = "t3.small"
      security_groups   = [aws_security_group.alb_aware.id]
      target_group_arns = [aws_lb_target_group.http.arn]
      user_data         = local.vclient
    }
  ]

  ### Initially, this module places all ec2 instances in a specific Availability Zone (AZ).
  ### This configuration is not fault tolerant when Single AZ goes down.
  ### After our first attempt at experimenting with 'terminte ec2 instances'
  ### we will scale the autoscaling-group cross-AZ for high availability.
  ###
  ### Switch the 'subnets' variable to the list of whole private subnets created in the example.

  subnets = [module.vpc.subnets["private"][var.azs[random_integer.az.result]]]
  # subnets = values(module.vpc.subnets["private"])
}

resource "aws_autoscaling_policy" "target-tracking" {
  name                   = local.asg_target_tracking_policy_name
  autoscaling_group_name = module.ec2.cluster.data_plane.node_groups.baseline.name
  adjustment_type        = "ChangeInCapacity"

  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 10.0
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

  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
  }
}
