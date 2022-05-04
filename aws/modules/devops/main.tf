#--------------------------------------------
# AWS ECR POC Configurations
#--------------------------------------------
resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.ecr_name
  image_tag_mutability = var.ecr_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }
}

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

  alarm_configuration {
    alarms                    = split(",", var.ecs_alarm_cpu_high_alarm_name)
    enabled                   = true
    ignore_poll_alarm_failure = true
  }

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
        listener_arns = split(",", var.aws_lb_listener_prod)
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

#--------------------------------------------
# AWS CodeBuild
#--------------------------------------------
# getting the current account ID
data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_codebuild_project" "terraform" {
  count          = length(var.project_names)
  name           = element(var.project_names, count.index)
  service_role   = aws_iam_role.codebuild_role.arn
  encryption_key = "arn:aws:kms:${var.region}:${local.account_id}:${var.encryption_key}"

  environment {
    image                       = "${local.account_id}.dkr.ecr.us-east-1.amazonaws.com/terraform:latest"
    compute_type                = var.environment_compute_type
    type                        = var.environment_type
    image_pull_credentials_type = var.environment_pull_type
    privileged_mode             = true
  }

  source {
    buildspec           = "terraform/buildspec_${element(var.project_names, count.index)}.yaml"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  artifacts {
    type                = "CODEPIPELINE"
    packaging           = "NONE"
    name                = element(var.project_names, count.index)
    encryption_disabled = false
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
}