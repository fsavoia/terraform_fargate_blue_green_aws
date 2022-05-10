variable "bucket_name_poc" {
  type        = string
  default     = "tfsate-backend-poc-05102022"  # replace here
  description = "Define Bucket for Terraform state file"
}

## DynamoDB
variable "dynamodb_table_name_poc" {
  type        = string
  default     = "terraform-state-lock"  # replace here
  description = "Define DynamoDB table for lock state"
}