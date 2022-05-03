#--------------------------------------------
# Deploy VPC Configurations
#--------------------------------------------
module "network" {
  source = "./aws/modules/network"
}

#--------------------------------------------
# Deploy EC2 Configurations
#--------------------------------------------
module "ec2" {
  source = "./aws/modules/ec2"

  name               = var.name
  instance_type      = var.instance_type
  aws_security_group = [module.network.aws_security_group]
  public_subnet_id   = module.network.public_subnet_id_a
}

#--------------------------------------------
# Deploy ECS Configurations
#--------------------------------------------
module "ecs" {
  source              = "./aws/modules/ecs"
  security_group      = [module.network.aws_security_group]
  subnets             = [module.network.public_subnet_id]
  vpc_id              = module.network.vpc_id
}

#--------------------------------------------
# Deploy DevOps Configurations
#--------------------------------------------
module "devops" {
  source = "./aws/modules/devops"
  # repo_name        = var.repo_name
  # repo_description = var.repo_description
  ecr_name                      = var.ecr_name
  ecs_cluster_name              = module.ecs.ecs_cluster_name
  ecs_service_name              = module.ecs.ecs_service_name
  ecs_alarm_cpu_high_alarm_name = module.ecs.ecs_alarm_cpu_high_alarm_name
  aws_lb_listener_prod          = module.ecs.aws_lb_listener_prod
  aws_lb_listener_test          = module.ecs.aws_lb_listener_test
  aws_lb_target_group_prod      = module.ecs.aws_lb_target_group_prod
  aws_lb_target_group_test      = module.ecs.aws_lb_target_group_test
}