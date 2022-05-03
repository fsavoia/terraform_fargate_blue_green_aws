variable "aws_lb_name" {
  type        = string
  default     = "lb-sample-app"
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

variable "subnets" {
  type        = list(string)
  description = "Define ALB public subnet id"
}

variable "alb_tg_prod_name" {
  type        = string
  default     = "tg-sample-app"
  description = "Define ALB target group name from production traffic"
}

variable "alb_tg_test_name" {
  type        = string
  default     = "tg-sample-app-test"
  description = "Define ALB target group name from production traffic"
}

variable "vpc_id" {
  type        = string
  description = "Define VPC ID"
}

variable "ecs_cluster_name" {
  type        = string
  default     = "poc-cluster"
  description = "Define ECS Cluster Name"
}

variable "capacity_providers" {
  type        = list(string)
  default = [ "FARGATE", "FARGATE_SPOT" ]
  description = "Define Cluster Capacity Provider"
}

variable "containerInsights" {
  type        = string
  default     = "disabled"
  description = "Define State from ECS containerInsights"
}