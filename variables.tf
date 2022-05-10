#--------------------------------------------
# Variables to deploy Network module
#--------------------------------------------
variable "availability_zones" {
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
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

variable "private_subnet_cidr_block_2" {
  type        = list(string)
  default     = ["100.70.5.0/25", "100.70.5.128/26", "100.70.5.192/26"]
  description = "Define private subnet CIDRs"
}