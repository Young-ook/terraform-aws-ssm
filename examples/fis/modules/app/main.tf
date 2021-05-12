### foundation/network
# vpc
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

### application/network
resource "aws_lb" "alb" {
  name                       = local.name
  tags                       = merge(local.default-tags, var.tags)
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = values(module.vpc.subnets["public"])
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
    cidr_blocks = ["0.0.0.0/0"]
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
  depends_on           = [aws_lb.alb]
  name                 = local.name
  tags                 = merge(local.default-tags, var.tags)
  vpc_id               = module.vpc.vpc.id
  port                 = 80
  protocol             = "HTTP"
  target_type          = "instance"
  deregistration_delay = 10

  health_check {
    enabled  = true
    interval = 30
    path     = "/"
    port     = "traffic-port"
    protocol = "HTTP"
  }

  lifecycle {
    create_before_destroy = true
  }
}

### application/ec2
module "ec2" {
  source  = "../../../../"
  name    = var.name
  tags    = var.tags
  subnets = values(module.vpc.subnets["private"])
  node_groups = [
    {
      name              = "web"
      min_size          = 1
      max_size          = 3
      desired_size      = 3
      instance_type     = "t3.small"
      security_groups   = [aws_security_group.alb.id]
      target_group_arns = [aws_lb_target_group.http.arn]
      user_data         = "#!/bin/bash\namazon-linux-extras install nginx1\nsystemctl start nginx"
    }
  ]
}
