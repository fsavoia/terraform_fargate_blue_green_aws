#Create a role
resource "aws_iam_role" "ec2_role" {
  name = var.role_name

  # Terraform's "jsonencode" function converts a expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#Attach role to an instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.ec2_profile
  role = aws_iam_role.ec2_role.name
}

#Attach SSM policy to Role
resource "aws_iam_policy_attachment" "ssm_policy_role" {
  name       = var.ssm_attachment
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = var.ssm_policy_arn
}

#Attach ECR policy to Role
resource "aws_iam_policy_attachment" "ecr_policy_role" {
  name       = var.ecr_attachment
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = var.ecr_policy_arn
}

#Attach ECS policy to Role
resource "aws_iam_policy_attachment" "ecs_policy_role" {
  name       = var.ecs_attachment
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = var.ecs_policy_arn
}