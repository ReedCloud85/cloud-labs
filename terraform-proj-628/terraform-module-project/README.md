Terraform AWS EC2 + S3 Project (Modularized)

This project uses Terraform to deploy a modular and reusable AWS infrastructure that
includes:

- An EC2 instance
- A custom IAM role with read-only access to S3
- An instance profile for role attachment
- A security group allowing SSH (and optionally HTTP)
- A reusable Terraform module for the web server

Project Structure:

terraform-aws-ec2-s3-project/
    main.tf               # Root configuration that calls the module
    variables.tf          # Root input variables
    outputs.tf            # Root outputs
    terraform_policy.json # IAM policy for S3 access
    modules/
      webserver/
        main.tf           # EC2 instance and security group
        variables.tf      # Input variables for module
        outputs.tf        # Module outputs
    README.md

What It Does:

- Creates a security group allowing SSH from a specified IP and optionally HTTP for web
access
- Deploys an EC2 instance using AMI and instance type variables
- Attaches an IAM role and instance profile to the EC2 for S3 access
- Wraps all EC2-related infrastructure in a reusable Terraform module

Module Inputs:
Variable                | Description                         | Example
------------------------|-------------------------------------|-------------------------
-----
ami_id                  | AMI ID for EC2                      | "ami-05df0ea761147eda6"
instance_type           | EC2 instance type                   | "t2.micro"
key_pair                | Name of the EC2 key pair            | "linuxlabs"
name                    | Tag to assign to the EC2 instance   | "Web_1"
instance_profile_name   | Name of the IAM instance profile    | "ec2-lab-profile"

IAM and Security:

- EC2 uses a role that grants read-only access to S3 via a custom IAM policy
- Security group restricts SSH access to a specified IP (edit this for production use)
- Policy is defined in terraform_policy.json and attached to the IAM role

Requirements:

- Terraform CLI v1.0 or higher
- AWS credentials configured via profile or environment variables
- A valid EC2 key pair already created in AWS
