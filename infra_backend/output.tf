output "s3_bucket" {
  value = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_main" {
  value = aws_dynamodb_table.state_lock_main.name
}

output "dynamodb_table_addon" {
  value = aws_dynamodb_table.state_lock_addon.name
}