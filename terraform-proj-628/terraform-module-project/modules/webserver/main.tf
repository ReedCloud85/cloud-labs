# Default VPC
data "aws_vpc" "default" {
  default = true
}

#Security Group
resource "aws_security_group" "sg_web" {
  name  = "terraform-web-sg"
  description = "Allow inbound SSH and HTTP"
  vpc_id  = data.aws_vpc.default.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<Public IP>/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# EC2 Instance
resource "aws_instance" "web" {
  ami  =  var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg_web.id]
  key_name = var.key_pair
  iam_instance_profile = var.instance_profile_name
  tags = {
    Name = var.name
  }
}
