#Cloudtrail trail for S3 Data Events
resource "aws_cloudtrail" "trail" {
  name                          = "codepipeline-source-trail"
  s3_bucket_name                = aws_s3_bucket.trail.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  enable_logging                = false
  is_multi_region_trail         = false
  enable_log_file_validation    = false
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = "${aws_iam_role.CloudTrail_Role.arn}"

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.artifact_store.arn}/${var.s3_object_key}"]
    }
  }
}

# Sending Events to CloudWatch Logs
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "CloudTrail/logs"
}