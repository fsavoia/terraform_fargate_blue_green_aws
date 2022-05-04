## Bucket
# variable "bucket_name" {
#   type        = string
#   default     = "terraform-backend-demo-fsavoia"
#   description = "Define Bucket for Terraform state file"
# }

variable "bucket_name_poc" {
  type        = string
  default     = "tfsate-backend-poc-fsavoia"
  description = "Define Bucket for Terraform state file"
}

# ## DynamoDB
# variable "dynamodb_table_name" {
#   type        = string
#   default     = "terraform-state-lock"
#   description = "Define DynamoDB table for lock state"
# }

## DynamoDB
variable "dynamodb_table_name_poc" {
  type        = string
  default     = "terraform-state-lock"
  description = "Define DynamoDB table for lock state"
}