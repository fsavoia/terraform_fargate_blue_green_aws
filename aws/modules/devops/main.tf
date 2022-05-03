#--------------------------------------------
# CodeCommit Repository
#--------------------------------------------
# resource "aws_codecommit_repository" "terraform" {
#   repository_name = var.repo_name
#   description     = var.repo_description
#   default_branch  = var.default_branch
# }

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
  app_name              = aws_codedeploy_app.codedeploy_ecs.name
  deployment_group_name = var.deployment_group_name
  service_role_arn      = var.deployment_service_role

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
# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name                  = var.codebuild_service_role
  assume_role_policy    = data.aws_iam_policy_document.role.json
  force_detach_policies = true
}

# IAM AssumeRole policy used by CodeBuild
data "aws_iam_policy_document" "role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }
}

# IAM policy document used by CodeBuild
resource "aws_iam_policy" "policy_document" {
  name = "iam_policy_default"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "cloudwatch:*",
          "autoscaling:*",
          "iam:CreateServiceLinkedRole",
          "s3-object-lambda:*",
          "dynamodb:*",
          "dax:*",
          "ecr:*",
          "logs:*",
          "codebuild:*"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

# Attach policy document to a CodeBuild role
resource "aws_iam_policy_attachment" "codebuil-iam-attach" {
  name       = "codebuild-policy-attachment"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = aws_iam_policy.policy_document.arn
}

resource "aws_codebuild_project" "terraform" {
  count          = length(var.project_names)
  name           = element(var.project_names, count.index)
  service_role   = aws_iam_role.codebuild_role.arn
  encryption_key = "arn:aws:kms:${var.region}:${var.account}:${var.encryption_key}"

  environment {
    image                       = var.environment_image
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

#--------------------------------------------
# AWS CodePipeline
#--------------------------------------------
# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name                  = var.codepipeline_service_role
  assume_role_policy    = data.aws_iam_policy_document.CodePipeline_AssumeRole.json
  force_detach_policies = true
}

# IAM AssumeRole policy used by CodePipeline
data "aws_iam_policy_document" "CodePipeline_AssumeRole" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    effect = "Allow"
  }
}

# IAM policy document used by CodePipeline
resource "aws_iam_policy" "pipeline_policy_document" {
  name = "iam_policy_default"
  policy = jsonencode({
    "Statement": [
        {
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Condition": {
                "StringEqualsIfExists": {
                    "iam:PassedToService": [
                        "cloudformation.amazonaws.com",
                        "elasticbeanstalk.amazonaws.com",
                        "ec2.amazonaws.com",
                        "ecs-tasks.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codestar-connections:UseConnection"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "elasticbeanstalk:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "cloudwatch:*",
                "s3:*",
                "sns:*",
                "cloudformation:*",
                "rds:*",
                "sqs:*",
                "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "lambda:InvokeFunction",
                "lambda:ListFunctions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "opsworks:CreateDeployment",
                "opsworks:DescribeApps",
                "opsworks:DescribeCommands",
                "opsworks:DescribeDeployments",
                "opsworks:DescribeInstances",
                "opsworks:DescribeStacks",
                "opsworks:UpdateApp",
                "opsworks:UpdateStack"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:UpdateStack",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild",
                "codebuild:BatchGetBuildBatches",
                "codebuild:StartBuildBatch"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "devicefarm:ListProjects",
                "devicefarm:ListDevicePools",
                "devicefarm:GetRun",
                "devicefarm:GetUpload",
                "devicefarm:CreateUpload",
                "devicefarm:ScheduleRun"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "servicecatalog:ListProvisioningArtifacts",
                "servicecatalog:CreateProvisioningArtifact",
                "servicecatalog:DescribeProvisioningArtifact",
                "servicecatalog:DeleteProvisioningArtifact",
                "servicecatalog:UpdateProduct"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:ValidateTemplate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImages"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:StartExecution"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "appconfig:StartDeployment",
                "appconfig:StopDeployment",
                "appconfig:GetDeployment"
            ],
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
})
}

# Attach policy document to a CodePipeline role
resource "aws_iam_policy_attachment" "codepipeline-iam-attach" {
  name       = "codepipeline-policy-attachment"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.pipeline_policy_document.arn
}

# CodePipeline Configuration
resource "aws_codepipeline" "codepipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "terraform-backend-demo-fsavoia"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "PollForSourceChanges" = "false"
        "S3Bucket"             = "terraform-backend-demo-fsavoia"
        "S3ObjectKey"          = "sample-app.zip"
      }
      name             = "Source"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "S3"
      region           = "us-east-1"
      run_order        = 1
      version          = "1"
    }
  }

  stage {
    name = "tfsec_check"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = "tfsec"
      }
      input_artifacts = ["SourceArtifact"]
      name            = "tfec_security"
      namespace       = "TFSEC"
      owner           = "AWS"
      provider        = "CodeBuild"
      region          = "us-east-1"
      run_order       = 1
      version         = "1"
    }
  }

  stage {
    name = "Terraform_Security"

    action {
      category = "Approval"
      configuration = {
        "CustomData"         = "tfsec errors found: #{TFSEC.checks_failed}"
        "ExternalEntityLink" = "https://#{TFSEC.Region}.console.aws.amazon.com/codesuite/codebuild/652839185683/projects/#{TFSEC.BuildID}/build/#{TFSEC.BuildID}%3A#{TFSEC.BuildTag}/?region=#{TFSEC.Region}"
      }
      name             = "Terraform_Security_Analysis_Manual_Review"
      output_artifacts = []
      owner            = "AWS"
      provider         = "Manual"
      region           = "us-east-1"
      run_order        = 1
      version          = "1"
    }
  }
  stage {
    name = "Terraform_Plan"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = "terraform_plan"
      }
      input_artifacts = ["SourceArtifact"]
      name            = "Terraform_Plan"
      namespace       = "TERRAFORM"
      owner           = "AWS"
      provider        = "CodeBuild"
      region          = "us-east-1"
      run_order       = 1
      version         = "1"
    }
  }
  stage {
    name = "Terraform_Plan_Manual_Review"

    action {
      category = "Approval"
      configuration = {
        "CustomData"         = "Terraform plan review"
        "ExternalEntityLink" = "https://#{TERRAFORM.Region}.console.aws.amazon.com/codesuite/codebuild/652839185683/projects/#{TERRAFORM.BuildID}/build/#{TERRAFORM.BuildID}%3A#{TERRAFORM.BuildTag}/?region=#{TERRAFORM.Region}"
      }
      name      = "Terraform_Plan_Manual_Review"
      owner     = "AWS"
      provider  = "Manual"
      region    = "us-east-1"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Terraform_Apply"

    action {
      category = "Build"
      configuration = {
        "ProjectName" = "terraform_apply"
      }
      input_artifacts = ["SourceArtifact"]
      name            = "Terraform_Apply"
      owner           = "AWS"
      provider        = "CodeBuild"
      region          = "us-east-1"
      run_order       = 1
      version         = "1"
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Approval"
      configuration = {
        "CustomData" = "Do you want to deploy application pro Prod?"
      }
      name      = "DeployToProd"
      owner     = "AWS"
      provider  = "Manual"
      region    = "us-east-1"
      run_order = 1
      version   = "1"
    }
    action {
      category = "Deploy"
      configuration = {
        "ApplicationName"     = "AppECS-awslabs-sample-svc-sample-app"
        "DeploymentGroupName" = "DgpECS-awslabs-sample-svc-sample-app"
      }
      input_artifacts = ["SourceArtifact"]
      name            = "Deploy"
      namespace       = "DeployVariables"
      owner           = "AWS"
      provider        = "CodeDeploy"
      region          = "us-east-1"
      run_order       = 2
      version         = "1"
    }
  }

}