#--------------------------------------------
# AWS CodeBuild
#--------------------------------------------
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