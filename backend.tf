terraform {
  backend "s3" {
    bucket         = "tfsate-backend-poc-05102022"
    key            = "poc.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}