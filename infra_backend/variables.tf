# variable "bucket_name_poc" {
#   type        = string
#   default     = "tfsate-backend-poc-050920222"  # replace here
#   description = "Define Bucket for Terraform state file"
# }

## DynamoDB
variable "dynamodb_table_name_poc" {
  type        = string
  default     = "terraform-state-addons-lock"  # replace here
  description = "Define DynamoDB table for lock state"
}