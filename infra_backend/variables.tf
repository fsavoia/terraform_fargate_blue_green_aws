variable "bucket_name" {
  type        = string
  default     = "tfsate-backend-demos-062022"
  description = "Define Bucket for Terraform state file"
}

## DynamoDB
variable "dynamodb_table_name_main" {
  type        = string
  default     = "tfstate-lock-demo-main"
  description = "Define DynamoDB table for lock state"
}

variable "dynamodb_table_name_addon" {
  type        = string
  default     = "tfstate-lock-demo-addon"
  description = "Define DynamoDB table for lock state"
}