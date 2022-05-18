# output "s3_bucket" {
#   value = aws_s3_bucket.tfstate_storage_poc.bucket
# }

output "dynamodb_table" {
  value = aws_dynamodb_table.state_lock_poc.name
}