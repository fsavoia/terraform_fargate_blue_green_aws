########################### PLEASE ATTENTION  ################################
# The task definition below should only be updated via CICD (CodeDeploy)
# Changes via Terraform will not be allowed
# Blue/Green deployment is being used
#-----------------------------------------------------------------------------
# PLEASE - DO NOT MODIFY THIS FILE AFTER DEPLOYMENT
#-----------------------------------------------------------------------------
data "aws_region" "current" {}

resource "aws_ecs_task_definition" "main" {
  container_definitions = jsonencode(
    [
      {
        image = var.image
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${var.family}"
            awslogs-region        = data.aws_region.current.name
            awslogs-stream-prefix = "ecs"
          }
        }
        memoryReservation = var.memory_reservation
        name              = var.container_name
        essential         = true
        portMappings = [
          {
            containerPort = var.container_port
            hostPort      = var.host_port
            protocol      = "tcp"
          }
        ]
      },
    ]
  )
  cpu                      = var.cpu
  task_role_arn            = aws_iam_role.task_role.arn
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  family                   = var.family
  memory                   = var.memory
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities

  depends_on = [
    aws_cloudwatch_log_group.ecs
  ]
}