variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Define region target"
}

variable "aws_lb_name" {
  type        = string
  default     = "lb-poc-app"
  description = "Define ALB name"
}

variable "deletion_protection" {
  type        = bool
  default     = true
  description = "Enable or Disable Deletion Protection for ALB"
}

variable "alb_internal" {
  type        = bool
  default     = false
  description = "Enable or Disable internal ALB"
}

variable "ip_address_type" {
  type        = string
  default     = "ipv4"
  description = "IP address type for ALB"
}
variable "load_balancer_type" {
  type        = string
  default     = "application"
  description = "Define ELB type"
}

variable "security_group" {
  type        = list(string)
  description = "Define Public Security Group"
}

variable "alb_security_group" {
  type        = string
  description = "Define Public Security Group"
}

variable "subnets" {
  type        = list(string)
  description = "Define ALB public subnet id"
}

variable "private_subnets" {
  type        = list(string)
  description = "Define ECS service private subnets id"
}

variable "alb_tg_prod_name" {
  type        = string
  default     = "tg-poc-app"
  description = "Define ALB target group name from production traffic"
}

variable "alb_tg_test_name" {
  type        = string
  default     = "tg-poc-app-test"
  description = "Define ALB target group name from production traffic"
}

variable "vpc_id" {
  type        = string
  description = "Define VPC ID"
}

variable "ecs_cluster_name" {
  type        = string
  default     = "poc-ecs-cluster"
  description = "Define ECS Cluster Name"
}

variable "capacity_providers" {
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
  description = "Define Cluster Capacity Provider"
}

variable "containerInsights" {
  type        = string
  default     = "disabled"
  description = "Define State from ECS containerInsights"
}

variable "launch_type" {
  type        = string
  default     = "FARGATE"
  description = "Define launch type for the ECS Services"
}

variable "ecs_service_name" {
  type        = string
  default     = "poc-ecs-svc"
  description = "Define ECS Service Name"
}

variable "ecs_platform_version" {
  type        = string
  default     = "1.4.0"
  description = "Define ECS Platform version"
}

variable "image" {
  type        = string
  description = "Define Standard Task Definition image"
}

variable "container_name" {
  type        = string
  default     = "poc-app"
  description = "Define container name"
}

variable "family" {
  type        = string
  default     = "task-poc-app"
  description = "Define the task definition family name"
}

variable "memory_reservation" {
  type        = number
  default     = 256
  description = "Define memory reservation for container"
}

variable "container_port" {
  type        = number
  default     = 3000
  description = "Define container port"
}

variable "host_port" {
  type        = number
  default     = 3000
  description = "Define host port"
}

variable "cpu" {
  type        = string
  default     = "512"
  description = "Define CPU for task definition"
}

variable "memory" {
  type        = string
  default     = "1024"
  description = "Define Memory for task definition"
}

variable "requires_compatibilities" {
  type        = list(string)
  default     = ["FARGATE"]
  description = "Define compabilitie for task definition"
}

variable "network_mode" {
  type        = string
  default     = "awsvpc"
  description = "Define network mode for task definition"
}

variable "deployment_controller" {
  type        = string
  default     = "CODE_DEPLOY"
  description = "Deployment controller type"
}

variable "ecr_repo_arns" {
  description = "The ARNs of the ECR repos.  By default, allows all repositories."
  type        = list(string)
  default     = ["*"]
}

variable "threshold_scale_up" {
  type        = number
  default     = 50
  description = "Define CPU threshold to scale up"
}

variable "threshold_scale_down" {
  type        = number
  default     = 45
  description = "Define CPU threshold to scale up"
}

variable "metric_name" {
  type        = string
  default     = "CPUUtilization"
  description = "Define the metric name for autoscale"
}

variable "scale_min_capacity" {
  type        = number
  default     = 1
  description = "Define min containers capacity for ECS Service Autoscale"
}

variable "scale_max_capacity" {
  type        = number
  default     = 2
  description = "Define max containers capacity for ECS Service Autoscale"
}

variable "scale_in_cooldown" {
  type        = number
  default     = 300
  description = "The amount of time, in seconds, after a scale in activity completes before another scale in activity can start"
}

variable "scale_out_cooldown" {
  type        = number
  default     = 2
  description = "The amount of time, in seconds, after a scale in activity completes before another scale in activity can start"
}

variable "target_value" {
  type        = number
  default     = 50
  description = "Define the target value for the metric"
}