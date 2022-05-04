# Create s3 bucket to store artifacts
resource "aws_s3_bucket" "artifact_store" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = false
  }

}

resource "aws_s3_bucket_versioning" "versioning_poc" {
  bucket = aws_s3_bucket.artifact_store.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_acls_poc" {
  bucket                  = aws_s3_bucket.artifact_store.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "acl_poc" {
  bucket = aws_s3_bucket.artifact_store.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "poc_kms" {
  bucket = aws_s3_bucket.artifact_store.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}