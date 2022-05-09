output "ecr_repo_arns" {
  value = aws_ecr_repository.ecr_repository.arn
}

output "ecr_repo_url" {
  value = aws_ecr_repository.ecr_repository.repository_url
}