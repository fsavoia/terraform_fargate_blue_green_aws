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