terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region  = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_iam_role" "s3readwrite" {
  name = "terr-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3readwrite" {
  name        = "ec2-s3-readwrite"
  description = "Policy that allows read and write access to s3 bucket"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Statement1",
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::terraform-proj-628/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role = aws_iam_role.s3readwrite.name
  policy_arn = aws_iam_policy.s3readwrite.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-lab-profile"
  role = aws_iam_role.s3readwrite.name
}

resource "aws_security_group" "sg_ssh" {
  name        = "terraform-ssh-sg"
  description = "Allow inbound SSH"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    from_port    = 22
    to_port      = 22
    protocol     = "tcp"
    cidr_blocks = ["<Personal Public IP>/32"]
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test_server" {
  ami                     = "ami-05df0ea761147eda6"
  instance_type           = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]
  key_name                = "linuxlabs"
  iam_instance_profile    = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = var.instance_name
  }
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "terraform-proj-628"
    Environment = "DevOpsTest"
  }
}

resource "aws_s3_bucket_versioning" "s3_version" {
  bucket = aws_s3_bucket.test_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}
