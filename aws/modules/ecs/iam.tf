data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_execution_role_policy_doc" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = var.ecr_repo_arns
  }
}

data "aws_iam_policy_document" "task_role_ecs_exec" {
  statement {
    sid    = "AllowECSExec"
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowDescribeLogGroups"
    actions = [
      "logs:DescribeLogGroups",
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowECSExecLogging"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "task_role" {
  name               = "ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role" "task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  name   = "${aws_iam_role.task_execution_role.name}-policy"
  role   = aws_iam_role.task_execution_role.name
  policy = data.aws_iam_policy_document.task_execution_role_policy_doc.json
}

resource "aws_iam_policy" "task_role_ecs_exec" {
  name        = "${aws_iam_role.task_role.name}-ecs-exec"
  description = "Allow ECS Exec with Cloudwatch logging when attached to an ECS task role"
  policy      = join("", data.aws_iam_policy_document.task_role_ecs_exec.*.json)
}

resource "aws_iam_role_policy_attachment" "task_role_ecs_exec" {
  role       = join("", aws_iam_role.task_role.*.name)
  policy_arn = join("", aws_iam_policy.task_role_ecs_exec.*.arn)
}