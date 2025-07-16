terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# Create VPC with public and private subnets. One Availability Zone (for simplicity)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "rds-vpc"
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone  = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Internet Gateway & Routing Tables
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "int-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_rt" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#Database subnet group
resource "aws_db_subnet_group" "db_subnet" {
  name = "rds-subnet-group"
  subnet_ids = [aws_subnet.private.id,aws_subnet.private_2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

# RDS Database
resource "aws_db_instance" "rds" {
  db_name = var.db_name
  engine = "mysql"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  username = var.username
  password = var.password
  multi_az = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet.id
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible = false
  skip_final_snapshot = true
}

#EC2 Instance (Install apache/worpress & connect to RDS endpoint)
resource "aws_instance" "web" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2 php php-mysql libapache2-mod-php mysql-client wget unzip

    systemctl start apache2
    systemctl enable apache2

    cd /var/www/html
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* .
    rm -rf wordpress latest.tar.gz

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${var.db_name}/" wp-config.php
    sed -i "s/username_here/${var.username}/" wp-config.php
    sed -i "s/password_here/${var.password}/" wp-config.php
    sed -i "s/localhost/${aws_db_instance.rds.address}/" wp-config.php

    chown -R www-data:www-data /var/www/html
  EOF


  tags = {
    Name = "wordpress-ec2"
  }
}

# EC2 and RDS security groups
resource "aws_security_group" "ec2" {
  name        = "wordpress-sg"
  description = "Allow inbound SSH & HTTP"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks = ["<Public IP>/32"]
  }  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow MySQL from EC2 security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

