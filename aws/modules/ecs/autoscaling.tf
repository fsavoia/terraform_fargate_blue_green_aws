# CLOUDWATCH ALARM to monitor the CPU utilization of a service
resource "aws_cloudwatch_metric_alarm" "alarm_scale_up" {
  actions_enabled   = true
  alarm_actions     = [aws_appautoscaling_policy.policy_scale_up.arn]
  alarm_description = "Scale up alarm for ECS service ${var.ecs_service_name}"
  alarm_name        = "alarm_${var.ecs_service_name}-up"
  namespace         = "AWS/ECS"

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.ecs_service_name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "CPUUtilization"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  treat_missing_data  = "missing"
  unit                = "Percent"
}

# CLOUDWATCH ALARM to monitor the CPU utilization of a service
resource "aws_cloudwatch_metric_alarm" "alarm_scale_down" {
  actions_enabled   = true
  alarm_actions     = [aws_appautoscaling_policy.policy_scale_down.arn]
  alarm_description = "Scale down alarm for ECS service ${var.ecs_service_name}"
  alarm_name        = "alarm_${var.ecs_service_name}-down"
  namespace         = "AWS/ECS"

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.ecs_service_name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 15
  metric_name         = "CPUUtilization"
  period              = 60
  statistic           = "Average"
  threshold           = 45
  treat_missing_data  = "missing"
  unit                = "Percent"
}

#Set up the target for autoscale in ECS service
data "aws_caller_identity" "current" {}
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_name}"
  role_arn = format(
    "arn:aws:iam::%s:role/aws-service-role/ecs.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_ECSService",
    data.aws_caller_identity.current.account_id,
  )

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#Set up the CPU utilization policy for scale down when the cloudwatch alarm gets triggered.
resource "aws_appautoscaling_policy" "policy_scale_down" {
  name               = "AGS_ECS_SCALE_DOWN_POLICY"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value       = 50
  }
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
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    target_value       = 50
    
  }
}
