# alb
resource "aws_lb" "alb" {
  name                       = local.name
  tags                       = merge(local.default-tags, var.tags)
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.subnets
  enable_deletion_protection = false
}

# security/firewall
resource "aws_security_group" "alb" {
  name        = join("-", [local.name, "alb"])
  description = format("security group for %s", local.name)
  tags        = merge(local.default-tags, var.tags)
  vpc_id      = var.vpc

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
  vpc_id               = var.vpc
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

resource "aws_autoscaling_attachment" "http" {
  autoscaling_group_name = var.asg
  alb_target_group_arn   = aws_lb_target_group.http.arn
}
