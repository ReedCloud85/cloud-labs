output "rds_endpoint" {
  description = "The connection endpoint of the RDS instance"
  value       = aws_db_instance.rds.endpoint
}

output "instance_public_ip_addr" {
  description = "Prints the public IP of the EC2 instance."
  value = aws_instance.web.public_ip
}
