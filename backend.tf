##########################################################################################
# Please, create your own tfstate backend bucket and dynamodb_table
##########################################################################################
terraform {
  backend "s3" {
    bucket         = "tfsate-backend-poc-05102022" # replace with your configuration
    key            = "poc_aws_ecs.tfstate"
    region         = "sa-east-1" # replace with your configuration
    dynamodb_table = "terraform-state-lock" # replace with your configuration
  }
}