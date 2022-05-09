# Private Security Groups - SG
resource "aws_security_group" "ecs_service" {
  name        = "${var.ecs_service_name}-private-sg"
  vpc_id      = var.vpc_id
  description = "Private security group to allow inbound/outbound from the ECS Service"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Default outbound traffic for private subnet"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.ecs_service_name}-private-sg"
  }
}

resource "aws_security_group_rule" "app_ecs_allow_traffic_from_alb" {
  description       = "Allow in ALB"
  security_group_id = aws_security_group.ecs_service.id

  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.alb_security_group
}