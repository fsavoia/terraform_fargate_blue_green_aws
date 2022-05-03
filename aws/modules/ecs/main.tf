#--------------------------------------------
# Deploy ECS Cluster
#--------------------------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name               = var.ecs_cluster_name
  capacity_providers = var.capacity_providers

  setting {
    name  = "containerInsights"
    value = var.containerInsights
  }
}

#--------------------------------------------
# Deploy ECS Service
#--------------------------------------------
resource "aws_ecs_service" "service" {
  cluster                            = "arn:aws:ecs:us-east-1:652839185683:cluster/awslabs-sample"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  enable_execute_command             = false
  health_check_grace_period_seconds  = 0
  iam_role                           = "aws-service-role"
  launch_type                        = "FARGATE"
  name                               = "svc-sample-app"
  platform_version                   = "1.4.0"
  task_definition                    = "td-sample-app:36"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    container_name   = "sample-app"
    container_port   = 3000
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:652839185683:targetgroup/tg-sample-app/4f4cfde710598ad1"
  }

  network_configuration {
    assign_public_ip = false
    security_groups  = ["sg-0e8c36962287b9e08"]
    subnets = [
      "subnet-014c10c58092823e7",
      "subnet-021f5ed3d0b8aa455",
      "subnet-0fc7f5b86e7078dda"
    ]
  }
}

#--------------------------------------------
# Deploy ECS Task Definition
#--------------------------------------------
resource "aws_ecs_task_definition" "taskdef" {
  container_definitions = jsonencode(
    [
      {
        image = "652839185683.dkr.ecr.us-east-1.amazonaws.com/sample-app:56"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/td-sample-app"
            awslogs-region        = "us-east-1"
            awslogs-stream-prefix = "ecs"
          }
        }
        memoryReservation = 256
        name              = "sample-app"
        essential         = true
        portMappings = [
          {
            containerPort = 3000
            hostPort      = 3000
            protocol      = "tcp"
          }
        ]
      },
    ]
  )
  cpu                      = "512"
  execution_role_arn       = "arn:aws:iam::652839185683:role/ecsTaskExecutionRole"
  family                   = "td-sample-app"
  memory                   = "1024"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}