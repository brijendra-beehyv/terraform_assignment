provider "aws" {
  region = "ap-south-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "bucket_id" {
  type = string
}

variable "role_name" {
  type = string
}

resource "aws_security_group" "a_sg" {
  name   = "a_sg"
  vpc_id = var.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 64000
    protocol    = "tcp"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = var.role_name
}

resource "aws_instance" "a_ec2" {
  ami                    = "ami-051a31ab2f4d498f5"
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.a_sg.id]
  key_name               = "mumbai key"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<EOF
#!/bin/bash
yum update -y
yum upgrade -y
yum install nginx -y

systemctl start nginx
systemctl enable nginx

aws s3 cp s3://${var.bucket_id}/files/index.html /home/ec2-user/
systemctl restart nginx
EOF
}

resource "aws_ebs_volume" "a_ebs" {
  size = 8
  type = "gp3"

  availability_zone = aws_instance.a_ec2.availability_zone
}

resource "aws_volume_attachment" "a_va" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.a_ebs.id
  instance_id = aws_instance.a_ec2.id
}

resource "aws_ebs_snapshot" "a_ebs_snapshot" {
  volume_id = aws_ebs_volume.a_ebs.id
}

resource "aws_ami_from_instance" "app_ami" {
  name               = "app-server-ami"
  source_instance_id = aws_instance.a_ec2.id
}

resource "aws_launch_template" "a_lt" {
  image_id      = aws_ami_from_instance.app_ami.id
  instance_type = "t2.micro"
  key_name      = "mumbai key"
  user_data     = base64encode("systemctl restart nginx")

  network_interfaces {
    subnet_id       = var.subnet_id
    security_groups = [aws_security_group.a_sg.id]
  }
}

output "instance_id" {
  value = aws_instance.a_ec2.id
}

output "launch_template_id" {
  value = aws_launch_template.a_lt.id
}
