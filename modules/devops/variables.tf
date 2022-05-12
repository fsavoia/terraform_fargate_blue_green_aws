#--------------------------------------------
# AWS ECR Configurations
#--------------------------------------------
variable "ecr_name" {
  type        = string
  default     = "sample-app"
  description = "Define ECR name used by POC application registry"
}

variable "ecr_tag_mutability" {
  type        = string
  default     = "IMMUTABLE"
  description = "Define TAG mutability"
}

#--------------------------------------------
# AWS CodeDeploy Configurations
#--------------------------------------------
variable "compute_platform" {
  type        = string
  default     = "ECS"
  description = "Define CodeDeploy Compute Platform"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Define ECS Cluster name"
}

variable "ecs_service_name" {
  type        = string
  description = "Define ECS Service name"
}

variable "deployment_name" {
  type        = string
  default     = "AppECS-poc-sample-svc-sample-app"
  description = "Define CodeDeploy Application Name"
}

variable "deployment_group_name" {
  type        = string
  default     = "DgpECS-poc-sample-svc-sample-app"
  description = "Define CodeDeploy Group Name"
}

variable "auto_rollback_events" {
  default     = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  type        = list(string)
  description = "The event type or types that trigger a rollback."
}

variable "deployment_config_name" {
  default     = "CodeDeployDefault.ECSLinear10PercentEvery1Minutes"
  type        = string
  description = "The name of the group's deployment config. The default is CodeDeployDefault.OneAtATime"
}

variable "action_on_timeout" {
  default     = "CONTINUE_DEPLOYMENT"
  type        = string
  description = "When to reroute traffic from an original environment to a replacement environment in a blue/green deployment."
}

variable "wait_time_in_minutes" {
  default     = 0
  type        = string
  description = "The number of minutes to wait before the status of a blue/green deployment changed to Stopped if rerouting is not started manually."
}

variable "termination_wait_time_in_minutes" {
  type        = string
  default     = 10
  description = "The number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment."
}

variable "aws_lb_listener_prod" {
  type        = string
  description = "The production listener ALB"
}

variable "aws_lb_listener_test" {
  type        = string
  description = "The test traffic listener ALB"
}

variable "aws_lb_target_group_prod" {
  type        = string
  description = "The target group name from production ALB"
}

variable "aws_lb_target_group_test" {
  type        = string
  description = "The target group name from test traffic ALB"
}