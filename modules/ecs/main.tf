#--------------------------------------------
# Deploy ECS Cluster
#--------------------------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = var.containerInsights
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = var.capacity_providers
}

# create log group to ecs
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.family}"
}