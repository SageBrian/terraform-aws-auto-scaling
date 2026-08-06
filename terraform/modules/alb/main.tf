resource "aws_lb" "web" {

  name = "${var.project_name}-alb"

  internal = false

  idle_timeout = 60

  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = [
    var.public_subnet_1_id,
    var.public_subnet_2_id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }

}

resource "aws_lb_target_group" "web" {

  name = "${var.project_name}-tg"

  port = 80

  protocol = "HTTP"

  target_type = "instance"

  vpc_id = var.vpc_id

  health_check {

    enabled = true

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    healthy_threshold = 2

    unhealthy_threshold = 2

    interval = 30

    timeout = 5

  }

}

resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.web.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.web.arn

  }

}