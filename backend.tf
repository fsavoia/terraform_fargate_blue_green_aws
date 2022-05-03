terraform {
  backend "s3" {
    bucket         = "tfsate-backend-poc-fsavoia"
    key            = "poc.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}