variable "name" {
  type        = string
  description = "Define the name of the network"
}

variable "vpc_cidr_block" {
  type        = string
  description = "Define VPC CIDR block"
}

variable "public_subnet_cidr_block" {
  type        = list(string)
  description = "Define public subnet CIDRs"
}

variable "private_subnet_cidr_block" {
  type        = list(string)
  description = "Define private subnet CIDRs"
}

variable "availability_zones" {
  type        = list(string)
  description = "Define subnets AZs"
}

variable "private_ports" {
  type        = list(number)
  default     = [80, 443, 8080]
  description = "Define ports for private SG"
}

variable "public_ports" {
  type        = list(number)
  default     = [80, 443, 8080]
  description = "Define ports for public SG"
}