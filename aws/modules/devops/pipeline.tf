#--------------------------------------------
# AWS CodePipeline
#--------------------------------------------
resource "aws_codepipeline" "codepipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "PollForSourceChanges" = "false"
        "S3Bucket"             = aws_s3_bucket.artifact_store.bucket
        "S3ObjectKey"          = var.s3_object_key
      }
      name             = "Source"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceArtifact"]
      owner            = "AWS"
      provider         = "S3"
      region           = var.region
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
      region          = var.region
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
        "ExternalEntityLink" = "https://#{TFSEC.Region}.console.aws.amazon.com/codesuite/codebuild/${local.account_id}/projects/#{TFSEC.BuildID}/build/#{TFSEC.BuildID}%3A#{TFSEC.BuildTag}/?region=#{TFSEC.Region}"
      }
      name             = "Terraform_Security_Analysis_Manual_Review"
      output_artifacts = []
      owner            = "AWS"
      provider         = "Manual"
      region           = var.region
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
      region          = var.region
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
        "ExternalEntityLink" = "https://#{TERRAFORM.Region}.console.aws.amazon.com/codesuite/codebuild/${local.account_id}/projects/#{TERRAFORM.BuildID}/build/#{TERRAFORM.BuildID}%3A#{TERRAFORM.BuildTag}/?region=#{TERRAFORM.Region}"
      }
      name      = "Terraform_Plan_Manual_Review"
      owner     = "AWS"
      provider  = "Manual"
      region    = var.region
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
      region          = var.region
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
      region    = var.region
      run_order = 1
      version   = "1"
    }
    action {
      category = "Deploy"
      configuration = {
        "ApplicationName"     = aws_codedeploy_app.codedeploy_ecs.name
        "DeploymentGroupName" = aws_codedeploy_deployment_group.codedeploygroup_ecs.deployment_group_name
      }
      input_artifacts = ["SourceArtifact"]
      name            = "Deploy"
      namespace       = "DeployVariables"
      owner           = "AWS"
      provider        = "CodeDeploy"
      region          = var.region
      run_order       = 2
      version         = "1"
    }
  }

}