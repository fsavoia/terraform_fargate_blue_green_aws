# # Create s3 bucket to store tfstate files 
# resource "aws_s3_bucket" "tfstate_storage_poc" {
#   bucket = var.bucket_name_poc

#   lifecycle {
#     prevent_destroy = false
#   }

# }

# resource "aws_s3_bucket_versioning" "versioning_poc" {
#   bucket = aws_s3_bucket.tfstate_storage_poc.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "block_public_acls_poc" {
#   bucket                  = aws_s3_bucket.tfstate_storage_poc.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_acl" "acl_poc" {
#   bucket = aws_s3_bucket.tfstate_storage_poc.id
#   acl    = "private"
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_poc" {
#   bucket = aws_s3_bucket.tfstate_storage_poc.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# Create Dynamo table for lock file
resource "aws_dynamodb_table" "state_lock_poc" {
  name           = var.dynamodb_table_name_poc
  hash_key       = "LockID"
  read_capacity  = 2
  write_capacity = 2

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

}