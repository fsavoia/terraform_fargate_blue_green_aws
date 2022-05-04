#--------------------------------------------
# Deploy EC2 Configurations
#--------------------------------------------
variable "instance_type" {
  type        = string
  description = "Define EC2 instance type"
}

variable "name" {
  type        = string
  description = "Define EC2 TAG name"
}