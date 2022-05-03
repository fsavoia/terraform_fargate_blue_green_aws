# # Create s3 bucket to store tfstate files 
# #tfsec:ignore:aws-s3-enable-bucket-logging
# resource "aws_s3_bucket" "terraform-tfstate-storage" {
#   bucket = var.bucket_name

#   lifecycle {
#     prevent_destroy = false
#   }

# }

# resource "aws_s3_bucket_versioning" "versioning" {
#   bucket = aws_s3_bucket.terraform-tfstate-storage.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "block_public_acls" {
#   bucket                  = aws_s3_bucket.terraform-tfstate-storage.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_acl" "acl" {
#   bucket = aws_s3_bucket.terraform-tfstate-storage.id
#   acl    = "private"
# }

# #tfsec:ignore:aws-s3-encryption-customer-key
# resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
#   bucket = aws_s3_bucket.terraform-tfstate-storage.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # Create Dynamo table for lock file
# #tfsec:ignore:aws-dynamodb-enable-at-rest-encryption
# #tfsec:ignore:aws-dynamodb-enable-recovery
# #tfsec:ignore:aws-dynamodb-table-customer-key
# resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
#   name           = var.dynamodb_table_name
#   hash_key       = "LockID"
#   read_capacity  = 2
#   write_capacity = 2

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   server_side_encryption {
#     enabled = true
#   }

# }