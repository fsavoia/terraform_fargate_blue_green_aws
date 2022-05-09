terraform {
  backend "s3" {
    bucket         = "tfsate-backend-poc-05092022"
    key            = "poc.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}