#Display public IP
output "instance_public_ip_addr" {
  description = "Prints the public IP of the EC2 instance."
  value       = aws_instance.web.public_ip
}

#Display Instance ID
output "instance_id" {
  value = aws_instance.web.id
}
