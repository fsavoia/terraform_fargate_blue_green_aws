output "vpc_id" {
  value = module.network.vpc_id
}

output "aws_public_security_group_id" {
  value = module.network.aws_security_group
}

output "public_subnet_ids" {
  value = module.network.public_subnet_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_id
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.ecr_repo.arn
}

output "private_subnet_id_2" {
  value = module.network.private_subnet_id_2
}