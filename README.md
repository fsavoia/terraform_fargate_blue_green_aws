# Fargate with Blue Green Deployment using Jenkins, AWS CodePipeline, AWS CodeBuid and AWS CodeDeploy

This example deploys a fully ECS Cluster with FARGATE mode. It creates all the necessary infrastructure, such as the VPC, Application Load Balancer and the necessary Roles in 3 availability zones.

It also creates all ECS setup, like cluster, service, tasks, auto scaling and the deploy mode (blue green).

### Jenkins

This example creates a Jenkins server on EC2. You should connect to http://<PUBLIC_IP_JENKINS>:8080 and follow the instructions. To get the admin password, you can connect on EC2 via SSM Sessions Manager.

* Create a Pipeline to get configuration via SCM (git). You can use Jenskinsfile on main branch from this [Sample Repository](https://github.com/fsavoia/amazon-ecs-demo-with-node-express)
* Replace your values on Jenkinsfile after deployment below.

### CI/CD

All deployment steps is done through a Pipeline using Jenkins for CI, CodePipeline, CodeBuild and CodeDeploy. In this example, the Terraform flow it's executed via AWS Codebuild before application deployment.

![hybrid_pipeline](images/hyrbrid_devops_aws.jpeg)

### tfsec

During the pipeline execution, we can check the security checks pased to our tfsec configuration 

![tfsec_output](images/tfsec_output.png)

This configuration is running inside of an AWS Codebuild Container ith the configuration stated at [buildspec_tfsec](https://github.com/fsavoia/amazon-ecs-demo-with-node-express/blob/main/terraform/buildspec_tfsec.yaml). We highly recommend you to check the [tfsec documentation](https://tfsec.dev/docs/aws/home/) to review the configuration and modify as you need.

Besides this output, AWS Codebuild also exports the result of tfsec report on the Codebuild reports section

![tfsec_output_report](images/tfsec_report.png)

Our pipeline have several manual process:
- Manual process to review the security checks passed via tfsec.
- Manual process to review the Terraform plan output.

![terraform_pipeline](images/terraform_pipeline.png)

## to-do
* Terraform: IAM policies more restrictive

## How to Deploy

### Prerequisites:

If you will use remote backend (recommended), please, you have to configure the file below (you have to create the resources before), otherwise, just simple remove this file for local backend

```shell script
backend.tf
```

If you want an example about how to create your remote backend infrastructure, go to [infra_backend](infra_backend) directory and replace [variables.tf](infra_backend/variables.tf) file with your data and follow the steps below

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform init
terraform plan
terraform apply
```


Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```shell script
git clone '<this repository>'
```

#### Step 2: Run Terraform INIT

Initialize a working directory with configuration files

```shell script
cd '<this repository directory>'
terraform init
```

#### Step 3: Run Terraform PLAN

Verify the resources created by this execution

```shell script
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 4: Terraform APPLY

to create resources

```shell script
terraform apply
```

Enter `yes` to apply

## How to Destroy

The following command destroys the resources created by `terraform apply`

```shell script
cd '<this repository directory>'
terraform destroy --auto-approve
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_devops"></a> [devops](#module\_devops) | ./modules/devops | n/a |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ./modules/ec2 | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Define subnets AZs | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Define EC2 instance type | `string` | `"jenkins-lab"` | no |
| <a name="input_name"></a> [name](#input\_name) | Define EC2 TAG name | `string` | `"t2.medium"` | no |
| <a name="input_object_lock_days"></a> [object\_lock\_days](#input\_object\_lock\_days) | The number of days that you want to specify for the default retention period | `number` | `365` | no |
| <a name="input_object_lock_mode"></a> [object\_lock\_mode](#input\_object\_lock\_mode) | The default Object Lock retention mode you want to apply to new objects placed in the specified bucket | `string` | `"GOVERNANCE"` | no |
| <a name="input_private_subnet_cidr_block"></a> [private\_subnet\_cidr\_block](#input\_private\_subnet\_cidr\_block) | Define private subnet CIDRs | `list(string)` | <pre>[<br>  "10.10.3.0/24",<br>  "10.10.4.0/24",<br>  "10.10.5.0/24"<br>]</pre> | no |
| <a name="input_public_subnet_cidr_block"></a> [public\_subnet\_cidr\_block](#input\_public\_subnet\_cidr\_block) | Define public subnet CIDRs | `list(string)` | <pre>[<br>  "10.10.0.0/24",<br>  "10.10.1.0/24",<br>  "10.10.2.0/24"<br>]</pre> | no |
| <a name="input_scale_max_capacity"></a> [scale\_max\_capacity](#input\_scale\_max\_capacity) | Define max containers capacity for ECS Service Autoscale | `number` | `2` | no |
| <a name="input_scale_min_capacity"></a> [scale\_min\_capacity](#input\_scale\_min\_capacity) | Define min containers capacity for ECS Service Autoscale | `number` | `1` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | Define VPC CIDR block | `string` | `"10.10.0.0/16"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Define the name of the network | `string` | `"poc-ecs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_public_security_group_id"></a> [aws\_public\_security\_group\_id](#output\_aws\_public\_security\_group\_id) | n/a |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | n/a |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->