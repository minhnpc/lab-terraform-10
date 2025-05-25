resource "aws_lb" "alb10" {
  name               = "${var.env}-alb"
  load_balancer_type = "application"
  security_groups    = [var.security_group_public_id]
  subnets            = [var.subnet_id[1], var.subnet_id[3]]
  tags = {
    Name = "${var.env}-lb"
  }
}

resource "aws_lb_listener" "lb_listener10_1" {
  load_balancer_arn = aws_lb.alb10.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.targetGr10[1].arn
        weight = 80
      }

      target_group {
        arn    = aws_lb_target_group.targetGr10[3].arn
        weight = 20
      }

      stickiness {
        enabled  = false
        duration = 1
      }
    }
  }
}

resource "aws_lb_target_group" "targetGr10" {
  vpc_id      = var.vpc_id
  count       = length(var.subnet_id)
  name_prefix = "Tgroup"
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"
  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "${var.env}-${(count.index + 1) % 2 == 1 ? "private" : "public"}-targetGroup"
  }
}
