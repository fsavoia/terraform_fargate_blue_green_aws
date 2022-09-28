#--------------------------------------------
# Deploy VPC Configurations
#--------------------------------------------
module "network" {
  source = "./modules/network"

  availability_zones        = var.availability_zones
  name                      = var.vpc_name
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
}

#--------------------------------------------
# Deploy EC2 Configurations
#--------------------------------------------
module "ec2" {
  source = "./modules/ec2"

  name               = var.name
  instance_type      = var.instance_type
  aws_security_group = [module.network.aws_security_group]
  public_subnet_id   = module.network.public_subnet_id_a
}

#--------------------------------------------
# Deploy ECS Configurations
#--------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  image              = module.devops.ecr_repo_url
  security_group     = [module.network.aws_security_group]
  alb_security_group = module.network.aws_security_group
  subnets            = module.network.public_subnet_id
  private_subnets    = module.network.private_subnet_id
  vpc_id             = module.network.vpc_id
  ecr_repo_arns      = [module.devops.ecr_repo_arns]
  scale_min_capacity = var.scale_min_capacity
  scale_max_capacity = var.scale_max_capacity
}

#--------------------------------------------
# Deploy DevOps Configurations
#--------------------------------------------
module "devops" {
  source = "./modules/devops"

  ecs_cluster_name         = module.ecs.ecs_cluster_name
  ecs_service_name         = module.ecs.ecs_service_name
  aws_lb_listener_prod     = module.ecs.aws_lb_listener_prod
  aws_lb_listener_test     = module.ecs.aws_lb_listener_test
  aws_lb_target_group_prod = module.ecs.aws_lb_target_group_prod
  aws_lb_target_group_test = module.ecs.aws_lb_target_group_test
  object_lock_mode         = var.object_lock_mode
  object_lock_days         = var.object_lock_days
}