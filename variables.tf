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

#--------------------------------------------
# Deploy DevOps Configurations
#--------------------------------------------
variable "repo_name" {
  type        = string
  description = "Define repository name"
}

variable "repo_description" {
  type        = string
  description = "Define repository description"
}

variable "ecr_name" {
  type        = string
  description = "Define ECR name"
}