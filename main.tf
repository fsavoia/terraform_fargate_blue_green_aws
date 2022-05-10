#--------------------------------------------
# Deploy VPC Configurations
#--------------------------------------------
module "network" {
  source = "./modules/network"

  availability_zones          = var.availability_zones
  name                        = var.vpc_name
  vpc_cidr_block              = var.vpc_cidr_block
  public_subnet_cidr_block    = var.public_subnet_cidr_block
  private_subnet_cidr_block   = var.private_subnet_cidr_block
  private_subnet_cidr_block_2 = var.private_subnet_cidr_block_2
}

#--------------------------------------------
# AWS ECR POC Configurations
#--------------------------------------------
resource "aws_ecr_repository" "ecr_repo" {
  name = "helloworld-grpc"

  image_scanning_configuration {
    scan_on_push = true
  }
}