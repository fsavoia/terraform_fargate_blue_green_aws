#--------------------------------------------
# AWS CodeDeploy Configurations
#--------------------------------------------
resource "aws_codedeploy_app" "codedeploy_ecs" {
  compute_platform = var.compute_platform
  name             = var.deployment_name
}

resource "aws_codedeploy_deployment_group" "codedeploygroup_ecs" {
  app_name               = aws_codedeploy_app.codedeploy_ecs.name
  deployment_config_name = var.deployment_config_name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = aws_iam_role.cdrole.arn

  auto_rollback_configuration {
    enabled = true
    events  = var.auto_rollback_events
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = var.action_on_timeout
      wait_time_in_minutes = var.wait_time_in_minutes
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {

    target_group_pair_info {
      prod_traffic_route {
        #listener_arns = split(",", var.aws_lb_listener_prod)
        listener_arns = [var.aws_lb_listener_default]
      }

      target_group {
        name = var.aws_lb_target_group_prod
      }
      target_group {
        name = var.aws_lb_target_group_test
      }

      test_traffic_route {
        listener_arns = split(",", var.aws_lb_listener_test)
      }
    }
  }
}