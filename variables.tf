#--------------------------------------------
# Variables to deploy EC2 module
#--------------------------------------------
variable "instance_type" {
  type        = string
  default     = "jenkins-lab"
  description = "Define EC2 instance type"
}

variable "name" {
  type        = string
  description = "Define EC2 TAG name"
  default     = "t2.medium"
}

#--------------------------------------------
# Variables to deploy Network module
#--------------------------------------------
variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  description = "Define subnets AZs"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.10.0.0/16"
  description = "Define VPC CIDR block"
}

variable "public_subnet_cidr_block" {
  type        = list(string)
  default     = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
  description = "Define public subnet CIDRs"
}

variable "private_subnet_cidr_block" {
  type        = list(string)
  default     = ["10.10.3.0/24", "10.10.4.0/24", "10.10.5.0/24"]
  description = "Define private subnet CIDRs"
}
variable "vpc_name" {
  type        = string
  default     = "poc-ecs"
  description = "Define the name of the network"
}

#--------------------------------------------
# Variables to deploy ECS module
#--------------------------------------------
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

#--------------------------------------------
# Variables to deploy DevOps module
#--------------------------------------------
variable "object_lock_mode" {
  type        = string
  default     = "GOVERNANCE"
  description = "The default Object Lock retention mode you want to apply to new objects placed in the specified bucket"
}

variable "object_lock_days" {
  type        = number
  default     = 1
  description = "The number of days that you want to specify for the default retention period"
}