# Data source to get IAM from Amazon linux 2
data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#EC2 with public subnet
resource "aws_instance" "public_instance" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.aws_security_group
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = var.name
  }

  user_data = <<EOF
  #!/bin/bash
  amazon-linux-extras install ansible2 -y && yum install git -y
  cd /etc/ansible && git clone https://github.com/fsavoia/amazon-ecs-demo-with-node-express.git app
  cd app/playbooks
  ansible-playbook install-jenkins-ec2.yml
EOF

}