## ec2 autoscaling groups with systems manager/session manager

module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

## features
locals {
  node_groups_enabled = (var.node_groups != null ? ((length(var.node_groups) > 0) ? true : false) : false)
}

## autoscaling groups (asg)
# security/policy
resource "aws_iam_role" "ng" {
  for_each = { for ng in var.node_groups : ng.name => ng }
  name     = join("-", [local.name, "ng", each.key])
  tags     = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("ec2.%s", module.aws.partition.dns_suffix)]
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ng-ssm" {
  for_each   = { for ng in var.node_groups : ng.name => ng }
  policy_arn = format("arn:%s:iam::aws:policy/AmazonSSMManagedInstanceCore", module.aws.partition.partition)
  role       = aws_iam_role.ng[each.key].id
}

resource "aws_iam_role_policy_attachment" "ng" {
  for_each = { for k, v in [for p in chunklist(flatten(
    [
      for k, v in var.node_groups : setproduct([v.name], v.policy_arns)
      if(length(lookup(v, "policy_arns", [])) > 0)
    ]), 2) :
    {
      role   = p[0]
      policy = p[1]
    }
  ] : k => v }
  policy_arn = each.value.policy
  role       = aws_iam_role.ng[each.value.role].id
}

resource "aws_iam_instance_profile" "ng" {
  for_each = { for ng in var.node_groups : ng.name => ng }
  role     = aws_iam_role.ng[each.key].id
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
    values = [length(regexall("ARM", lookup(each.value, "ami_type", "AL2_x86_64"))) > 0 ? "arm64" : "x86_64"]
  }
}

data "cloudinit_config" "ng" {
  for_each      = { for ng in var.node_groups : ng.name => ng }
  base64_encode = true
  gzip          = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
    #!/bin/bash
    sudo yum update -y
    yum install -y amazon-cloudwatch-agent
    EOT
  }

  part {
    content_type = "text/x-shellscript"
    content      = lookup(each.value, "user_data", "")
  }
}

resource "aws_launch_template" "ng" {
  for_each      = { for ng in var.node_groups : ng.name => ng }
  name          = join("-", [local.name, each.key])
  tags          = merge(local.default-tags, var.tags, lookup(each.value, "tags", {}))
  image_id      = lookup(each.value, "image_id", data.aws_ami.al2[each.key].id)
  user_data     = data.cloudinit_config.ng[each.key].rendered
  instance_type = lookup(each.value, "instance_type", "t3.medium")
  key_name      = lookup(each.value, "key_name", null)

  iam_instance_profile {
    arn = aws_iam_instance_profile.ng[each.key].arn
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
    security_groups       = lookup(each.value, "security_groups", [])
    delete_on_termination = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.default-tags, var.tags, lookup(each.value, "tags", {}))
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_autoscaling_group" "ng" {
  for_each              = { for ng in var.node_groups : ng.name => ng }
  name                  = join("-", [local.name, each.key])
  vpc_zone_identifier   = var.subnets
  max_size              = lookup(each.value, "max_size", 3)
  min_size              = lookup(each.value, "min_size", 1)
  desired_capacity      = lookup(each.value, "desired_size", 1)
  target_group_arns     = lookup(each.value, "target_group_arns", null)
  force_delete          = true
  protect_from_scale_in = false
  termination_policies  = ["Default"]
  enabled_metrics = [
    "GroupPendingInstances", "GroupStandbyInstances", "GroupInServiceInstances", "GroupMinSize",
    "GroupTerminatingInstances", "GroupDesiredCapacity", "GroupTotalInstances", "GroupMaxSize",
  ]

  dynamic "mixed_instances_policy" {
    for_each = (length(lookup(each.value, "warm_pool", [])) == 0 ? [each.value] : [])
    content {
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.ng[mixed_instances_policy.value.name].id
          version            = aws_launch_template.ng[mixed_instances_policy.value.name].latest_version
        }

        dynamic "override" {
          for_each = lookup(mixed_instances_policy.value, "instances_override", [])
          content {
            instance_type     = lookup(override.value, "instance_type", null)
            weighted_capacity = lookup(override.value, "weighted_capacity", null)
          }
        }
      }

      dynamic "instances_distribution" {
        for_each = { for k, v in mixed_instances_policy.value : k => v if k == "instances_distribution" }
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
  }

  dynamic "launch_template" {
    for_each = (length(lookup(each.value, "warm_pool", [])) > 0 ? [each.value] : [])
    content {
      id      = aws_launch_template.ng[launch_template.value.name].id
      version = aws_launch_template.ng[launch_template.value.name].latest_version
    }
  }

  dynamic "warm_pool" {
    for_each = flatten([lookup(each.value, "warm_pool", [])])
    content {
      pool_state                  = lookup(warm_pool.value, "pool_state", "Stopped")
      min_size                    = lookup(warm_pool.value, "min_pool_size", 0)
      max_group_prepared_capacity = lookup(warm_pool.value, "max_group_prepared_capacity", 0)
    }
  }

  dynamic "tag" {
    for_each = merge(
      { "Name" = join("-", [local.name, each.key]) },
      local.default-tags,
      var.tags,
      lookup(each.value, "tags", {})
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  depends_on = [
    aws_launch_template.ng,
  ]
}
