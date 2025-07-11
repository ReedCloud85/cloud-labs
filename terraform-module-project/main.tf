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

module "webserver" {
  source = "./modules/webserver"
  ami_id = "ami-05df0ea761147eda6"
  instance_type = "t2.micro"
  key_pair = "linuxlabs"
  bucket_name = "modulebucket710"
  name = "Web_1"
  instance_profile_name = aws_iam_instance_profile.ec2_profile.name
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

resource "aws_s3_bucket_versioning" "s3_version" {
  bucket = "modulebucket710"

  versioning_configuration {
    status = "Enabled"
  }
}
