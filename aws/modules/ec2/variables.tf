variable "instance_type" {
  type        = string
  description = "Define EC2 instance type"
}

variable "name" {
  type        = string
  description = "Define EC2 TAG name"
}

variable "aws_security_group" {
  type        = list(string)
  description = "Define EC2 Security Group"
}

variable "public_subnet_id" {
  type        = string
  description = "Define EC2 public subnet id"
}

#IAM configuration for EC2
variable "role_name" {
  type        = string
  default     = "ec2_instance_role"
  description = "Define Role name for the EC2 Instance Profile"
}

variable "ssm_attachment" {
  type        = string
  default     = "ssm_attachment"
  description = "Define the name of SSM policy attachment"
}

variable "codepipeline_attachment" {
  type        = string
  default     = "codepipeline_attachment"
  description = "Define the name of Codepipeline policy attachment"
}

variable "ecr_attachment" {
  type        = string
  default     = "ecr_attachment"
  description = "Define the name of ECR policy attachment"
}

variable "s3_attachment" {
  type        = string
  default     = "s3_attachment"
  description = "Define the name of ECR policy attachment"
}

variable "ecs_attachment" {
  type        = string
  default     = "ecs_attachment"
  description = "Define the name of ECR policy attachment"
}

variable "ec2_profile" {
  type        = string
  default     = "ec2_instance_profile"
  description = "Define the name of EC2 instance profile"
}

variable "ssm_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  description = "Define ARN for AmazonEC2RoleforSSM AWS managed policy"
}

variable "codepipeline_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/AWSCodePipelineCustomActionAccess"
  description = "Define ARN for AWSCodePipelineCustomActionAccess AWS managed policy"
}

variable "ecr_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  description = "Define ARN for EC2InstanceProfileForImageBuilderECRContainerBuilds AWS managed policy"
}

variable "s3_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  description = "Define ARN for AmazonS3FullAccess AWS managed policy"
}

variable "ecs_policy_arn" {
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  description = "Define ARN for AmazonECS_FullAccess AWS managed policy"
}