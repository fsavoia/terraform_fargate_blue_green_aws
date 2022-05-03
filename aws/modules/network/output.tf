output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "aws_security_group" {
  value = aws_security_group.public.id
}

output "public_subnet_id" {
  value = join("", aws_subnet.public[*].id)
}

output "private_subnet_id" {
  value = join("", aws_subnet.private[*].id)
}

output "public_subnet_id_a" {
  value = aws_subnet.public[0].id
}