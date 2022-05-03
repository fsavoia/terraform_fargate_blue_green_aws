#--------------------------------------------
# Deploy ALB Configurations
#--------------------------------------------
resource "aws_lb" "alb" {
  name                       = var.aws_lb_name
  enable_deletion_protection = var.deletion_protection
  internal                   = var.alb_internal
  ip_address_type            = var.ip_address_type
  load_balancer_type         = var.load_balancer_type
  security_groups            = var.security_group
  subnets                    = var.subnets
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg_http.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_test" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg_http_test.arn
    type             = "forward"
  }

}

resource "aws_lb_target_group" "tg_http" {
  deregistration_delay = "300"
  name                 = var.alb_tg_prod_name
  port                 = 80
  protocol             = "HTTP"
  protocol_version     = "HTTP1"
  target_type          = "ip"
  vpc_id               = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}


resource "aws_lb_target_group" "tg_http_test" {
  deregistration_delay = "300"
  name                 = var.alb_tg_test_name
  port                 = 80
  protocol             = "HTTP"
  protocol_version     = "HTTP1"
  target_type          = "ip"
  vpc_id               = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}