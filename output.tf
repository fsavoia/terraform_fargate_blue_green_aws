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
