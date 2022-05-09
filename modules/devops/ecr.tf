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