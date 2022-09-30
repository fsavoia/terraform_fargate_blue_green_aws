# IAM Role for CodeDeploy
resource "aws_iam_role" "cdrole" {
  name = "CodeDeploy-ServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#IAM attachment for AWSCodeDeployRoleForECS role
resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.cdrole.name
}


#IAM Role for EventBridge to start CodePipeline
resource "aws_iam_role" "cwe" {
  name = "cwe-role-${var.region}-${aws_codepipeline.codepipeline.name}"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# IAM policy document used by EventBridge
resource "aws_iam_policy" "cwe_document" {
  name = "start-pipeline-execution-${var.region}-${aws_codepipeline.codepipeline.name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codepipeline:StartPipelineExecution"
        ],
        "Resource" : [
          "${aws_codepipeline.codepipeline.arn}"
        ]
      }
    ]
  })
}

#IAM attachment for EventBridge role
resource "aws_iam_role_policy_attachment" "cwe_attachment" {
  policy_arn = aws_iam_policy.cwe_document.arn
  role       = aws_iam_role.cwe.name
}

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
  name = "CodeBuild_iam_policy_default"
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
  name = "CodePipeline_iam_policy_default"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "iam:PassRole"
        ],
        "Resource" : "*",
        "Effect" : "Allow",
        "Condition" : {
          "StringEqualsIfExists" : {
            "iam:PassedToService" : [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        "Action" : [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "codestar-connections:UseConnection"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
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
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
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
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "devicefarm:ListProjects",
          "devicefarm:ListDevicePools",
          "devicefarm:GetRun",
          "devicefarm:GetUpload",
          "devicefarm:CreateUpload",
          "devicefarm:ScheduleRun"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:CreateProvisioningArtifact",
          "servicecatalog:DescribeProvisioningArtifact",
          "servicecatalog:DeleteProvisioningArtifact",
          "servicecatalog:UpdateProduct"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudformation:ValidateTemplate"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:DescribeImages"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "states:DescribeExecution",
          "states:DescribeStateMachine",
          "states:StartExecution"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "appconfig:StartDeployment",
          "appconfig:StopDeployment",
          "appconfig:GetDeployment"
        ],
        "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

# Attach policy document to a CodePipeline role
resource "aws_iam_policy_attachment" "codepipeline-iam-attach" {
  name       = "codepipeline-policy-attachment"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.pipeline_policy_document.arn
}


# Creating CloudTrail_CloudWatchLogs_Role
resource "aws_iam_policy" "Cloudtrail-CloudWatchLogs" {
  name        = "Cloudtrail-CloudWatchLogs"
  path        = "/"
  description = "Cloudtrail-CloudWatchLogs"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
            ]
        }
    ]
}
EOF
}

# IAM Role for Cloudtrail
resource "aws_iam_role" "CloudTrail_Role" {
  name               = "CloudTrail_CloudWatchLogs_Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policy document to a role
resource "aws_iam_policy_attachment" "CloudTrail_iam_attach" {
  name       = "cloudtrail_policy_attachment"
  roles      = ["${aws_iam_role.CloudTrail_Role.name}"]
  policy_arn = aws_iam_policy.Cloudtrail-CloudWatchLogs.arn
}