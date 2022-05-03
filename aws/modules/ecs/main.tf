#--------------------------------------------
# Deploy ALB Configurations
#--------------------------------------------
resource "aws_lb" "alb" {
  name                       = "lb-sample-app"
  enable_deletion_protection = true
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  security_groups            = ["sg-0b270f8d1addd1001"]
  subnets = [
    "subnet-05b56cd33b4d09210",
    "subnet-0816e09adbe325023",
    "subnet-0e7ff3c0fa763f5bb"
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:652839185683:loadbalancer/app/lb-sample-app/13a1ef593afbe500"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:652839185683:targetgroup/tg-sample-app/4f4cfde710598ad1"
    type             = "forward"
  }
}

resource "aws_lb_listener" "http_test" {
  load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:652839185683:loadbalancer/app/lb-sample-app/13a1ef593afbe500"
  port              = 8080
  protocol          = "HTTP"

  default_action {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:652839185683:targetgroup/tg-sample-app/4f4cfde710598ad1"
    type             = "forward"
  }

}

resource "aws_lb_target_group" "tg_http" {
  deregistration_delay = "300"
  name                 = "tg-sample-app"
  port                 = 80
  protocol             = "HTTP"
  protocol_version     = "HTTP1"
  target_type          = "ip"
  vpc_id               = "vpc-0d15f08d7d6613317"

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
  name                 = "tg-awslab-svc-sample-app-2"
  port                 = 80
  protocol             = "HTTP"
  protocol_version     = "HTTP1"
  target_type          = "ip"
  vpc_id               = "vpc-0d15f08d7d6613317"

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

#--------------------------------------------
# Deploy ECS Cluster
#--------------------------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "awslabs-sample"
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

######################################################################################
####################### AUTO SCALING & CLOUD WATCH ALARMS ############################
########## The autoscaling policies to scale the ecs service up and down. ############
######################################################################################
# CLOUDWATCH ALARM to monitor the CPU utilization of a service
resource "aws_cloudwatch_metric_alarm" "high" {
  actions_enabled     = true
  alarm_actions       = ["arn:aws:autoscaling:us-east-1:652839185683:scalingPolicy:b7b87dd4-07cc-440f-accf-42449e8eb925:resource/ecs/service/awslabs-sample/svc-sample-app:policyName/AGS_ECS_POLICY:createdBy/43c0fbae-d4bf-4834-8d78-1dd556355175"]
  alarm_description   = "DO NOT EDIT OR DELETE. For TargetTrackingScaling policy arn:aws:autoscaling:us-east-1:652839185683:scalingPolicy:b7b87dd4-07cc-440f-accf-42449e8eb925:resource/ecs/service/awslabs-sample/svc-sample-app:policyName/AGS_ECS_POLICY:createdBy/43c0fbae-d4bf-4834-8d78-1dd556355175."
  alarm_name          = "TargetTracking-service/awslabs-sample/svc-sample-app-AlarmHigh-eb802abf-e768-43f1-a5f3-196829f3a1cd"
  comparison_operator = "GreaterThanThreshold"
  dimensions = {
    "ClusterName" = "awslabs-sample"
    "ServiceName" = "svc-sample-app"
  }
  evaluation_periods = 3
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = 60
  statistic          = "Average"
  threshold          = 50
  treat_missing_data = "missing"
  unit               = "Percent"
}

# CLOUDWATCH ALARM to monitor the CPU utilization of a service
resource "aws_cloudwatch_metric_alarm" "low" {
  actions_enabled = true
  alarm_actions = [
  "arn:aws:autoscaling:us-east-1:652839185683:scalingPolicy:b7b87dd4-07cc-440f-accf-42449e8eb925:resource/ecs/service/awslabs-sample/svc-sample-app:policyName/AGS_ECS_POLICY:createdBy/43c0fbae-d4bf-4834-8d78-1dd556355175"]
  alarm_description   = "DO NOT EDIT OR DELETE. For TargetTrackingScaling policy arn:aws:autoscaling:us-east-1:652839185683:scalingPolicy:b7b87dd4-07cc-440f-accf-42449e8eb925:resource/ecs/service/awslabs-sample/svc-sample-app:policyName/AGS_ECS_POLICY:createdBy/43c0fbae-d4bf-4834-8d78-1dd556355175."
  alarm_name          = "TargetTracking-service/awslabs-sample/svc-sample-app-AlarmLow-84675e38-037a-473d-a4bb-f611c9b00ba1"
  comparison_operator = "LessThanThreshold"
  dimensions = {
    "ClusterName" = "awslabs-sample"
    "ServiceName" = "svc-sample-app"
  }
  evaluation_periods = 15
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = 60
  statistic          = "Average"
  threshold          = 45
  treat_missing_data = "missing"
  unit               = "Percent"
}


#Set up the target for autoscale
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/awslabs-sample/svc-sample-app"
  role_arn           = "arn:aws:iam::652839185683:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#Set up the CPU utilization policy for scale down when the cloudwatch alarm gets triggered.
resource "aws_appautoscaling_policy" "policy_scale_down" {
  name               = "AGS_ECS_POLICY"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/awslabs-sample/svc-sample-app"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value       = 50

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

#Set up the CPU utilization policy for scale up when the cloudwatch alarm gets triggered.
resource "aws_appautoscaling_policy" "policy_scale_up" {
  name               = "AGS_ECS_POLICY"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/awslabs-sample/svc-sample-app"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value       = 50

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
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