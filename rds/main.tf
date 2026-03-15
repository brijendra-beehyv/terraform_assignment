provider "aws" {
  region = "ap-south-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ec2_instance_id" {
  type = string
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-security-group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = [var.subnet_id]

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier = "my-database"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t2.micro"

  allocated_storage = 20

  db_name  = "appdb"
  username = "admin"
  password = "StrongPassword123!"

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
}

resource "aws_db_instance" "read_replica" {
  identifier = "my-db-replica"

  replicate_source_db = aws_db_instance.main.identifier
  instance_class      = "db.t2.micro"

  publicly_accessible = false
  skip_final_snapshot = true
}
