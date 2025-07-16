# Terraform WordPress on AWS (RDS + EC2 Project)

This project uses Terraform to provision a WordPress website on AWS using:

- EC2 (for the web server)
- RDS (for MySQL database)
- Custom VPC with public/private subnets
- Security Groups for proper isolation
- User data scripts to automatically install Apache, PHP, and WordPress

# Lessons Learned

- Writing Terraform from raw resources improved my understanding of AWS networking, security groups, and automation

- Debugging real-world issues like database access and provisioning delays strengthened my troubleshooting skills
