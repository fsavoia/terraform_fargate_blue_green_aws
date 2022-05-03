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
