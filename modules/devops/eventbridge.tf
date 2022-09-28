#EventBride rule to start CodePipeline
resource "aws_cloudwatch_event_rule" "codepipeline" {
  name        = "${aws_codepipeline.codepipeline.name}-rule"
  description = var.eventbridge_rule_description

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutObject", "CompleteMultipartUpload", "CopyObject"],
    "requestParameters": {
      "bucketName": ["${aws_s3_bucket.artifact_store.bucket}"],
      "key": ["${var.s3_object_key}"]
    }
  }
}
EOF
}

#EventBride target rule to start CodePipeline
resource "aws_cloudwatch_event_target" "codepipeline_target" {
  rule     = aws_cloudwatch_event_rule.codepipeline.name
  arn      = aws_codepipeline.codepipeline.arn
  role_arn = aws_iam_role.cwe.arn
}

#Cloudtrail trail for S3 Data Events
resource "aws_cloudtrail" "trail" {
  name                          = "codepipeline-source-trail"
  s3_bucket_name                = aws_s3_bucket.trail.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.artifact_store.arn}/${var.s3_object_key}"]
    }
  }
}