## ec2 autoscaling groups with systems manager/session manager

module "current" {
  source  = "Young-ook/spinnaker/aws//modules/aws-partitions"
  version = ">= 2.0"
}

## autoscaling groups (asg)
# security/policy
resource "aws_iam_role" "asg" {
  name = join("-", [local.name, "asg"])
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("ec2.%s", module.current.partition.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "ssm-managed" {
  policy_arn = format("arn:%s:iam::aws:policy/AmazonSSMManagedInstanceCore", module.current.partition.partition)
  role       = aws_iam_role.asg.id
}

resource "aws_iam_role_policy_attachment" "extra" {
  for_each   = { for key, val in var.policy_arns : key => val }
  policy_arn = each.value
  role       = aws_iam_role.asg.id
}

resource "aws_iam_instance_profile" "asg" {
  role = aws_iam_role.asg.name
}

## amazon-linux 2
data "aws_ami" "al2" {
  for_each    = { for ng in var.node_groups : ng.name => ng }
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = [format("amzn2-ami-hvm-*")]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = [lookup(each.value, "volume_type", "gp2")]
  }
  filter {
    name   = "architecture"
    values = [lookup(each.value, "arch", "x86_64")]
  }
}

data "template_file" "boot" {
  for_each = { for ng in var.node_groups : ng.name => ng }
  template = <<EOT
#!/bin/bash
set -ex
EOT
}

resource "aws_launch_template" "asg" {
  for_each      = { for ng in var.node_groups : ng.name => ng }
  name          = join("-", [local.name, each.key])
  tags          = merge(local.default-tags, var.tags)
  image_id      = data.aws_ami.al2[each.key].id
  user_data     = base64encode(data.template_file.boot[each.key].rendered)
  instance_type = lookup(each.value, "instance_type", "t3.medium")

  iam_instance_profile {
    arn = aws_iam_instance_profile.asg.arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = lookup(each.value, "disk_size", "20")
      volume_type           = lookup(each.value, "volume_type", "gp2")
      delete_on_termination = true
    }
  }

  network_interfaces {
    #    security_groups       = []
    delete_on_termination = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.default-tags, var.tags)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_autoscaling_group" "asg" {
  for_each              = { for ng in var.node_groups : ng.name => ng }
  name                  = join("-", [local.name, each.key])
  vpc_zone_identifier   = local.subnet_ids
  max_size              = lookup(each.value, "max_size", 3)
  min_size              = lookup(each.value, "min_size", 1)
  desired_capacity      = lookup(each.value, "desired_size", 1)
  force_delete          = true
  protect_from_scale_in = false
  termination_policies  = ["Default"]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.asg[each.key].id
        version            = aws_launch_template.asg[each.key].latest_version
      }

      dynamic "override" {
        for_each = lookup(each.value, "instances_override", [])
        content {
          instance_type     = lookup(override.value, "instance_type", null)
          weighted_capacity = lookup(override.value, "weighted_capacity", null)
        }
      }
    }

    dynamic "instances_distribution" {
      for_each = { for key, val in each.value : key => val if key == "instances_distribution" }
      content {
        on_demand_allocation_strategy            = lookup(instances_distribution.value, "on_demand_allocation_strategy", null)
        on_demand_base_capacity                  = lookup(instances_distribution.value, "on_demand_base_capacity", null)
        on_demand_percentage_above_base_capacity = lookup(instances_distribution.value, "on_demand_percentage_above_base_capacity", null)
        spot_allocation_strategy                 = lookup(instances_distribution.value, "spot_allocation_strategy", null)
        spot_instance_pools                      = lookup(instances_distribution.value, "spot_instance_pools", null)
        spot_max_price                           = lookup(instances_distribution.value, "spot_max_price", null)
      }
    }
  }

  dynamic "tag" {
    for_each = merge(
      { "Name" = join("-", [local.name, each.key]) },
      local.default-tags,
      var.tags
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity, name]
  }

  depends_on = [
    aws_iam_role.asg,
    aws_launch_template.asg,
  ]
}
