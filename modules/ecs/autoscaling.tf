#Set up the target for autoscale in ECS service
data "aws_caller_identity" "current" {}
resource "aws_appautoscaling_target" "ecs_target" {
  min_capacity = var.scale_min_capacity
  max_capacity = var.scale_max_capacity
  resource_id  = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.service.name}"
  role_arn = format(
    "arn:aws:iam::%s:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService",
    data.aws_caller_identity.current.account_id,
  )

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#Set up the CPU utilization policy for scale up when the cloudwatch alarm gets triggered.
resource "aws_appautoscaling_policy" "policy_scale_up" {
  name               = "AGS_ECS_SCALE_UP_POLICY"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
    target_value       = var.target_value

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

  }
}
