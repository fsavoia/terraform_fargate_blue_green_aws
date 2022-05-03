#--------------------------------------------
# Deploy EC2 Configurations
#--------------------------------------------
name          = "jenkins-lab"
instance_type = "t2.medium"

#--------------------------------------------
# Deploy DevOps Configurations
#--------------------------------------------
repo_name        = "sample-app-awslabs"
repo_description = "Sample App repository to test AWS DevOps tools"
ecr_name         = "sample-app"