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

#S3 for Cloudtrail used by S3 data events
resource "aws_s3_bucket" "trail" {
  bucket              = "cloudtrail-codepipeline-${aws_codepipeline.codepipeline.name}"
  force_destroy       = true
  object_lock_enabled = var.object_lock_enabled
}

resource "aws_s3_bucket_object_lock_configuration" "object_lock_trail" {
  bucket = aws_s3_bucket.trail.id

  rule {
    default_retention {
      mode = var.object_lock_mode
      days = var.object_lock_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_acls_trail" {
  bucket                  = aws_s3_bucket.trail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "acl_trail" {
  bucket = aws_s3_bucket.trail.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail_kms" {
  bucket = aws_s3_bucket.trail.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.trail.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.trail.arn}/prefix/AWSLogs/${local.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}