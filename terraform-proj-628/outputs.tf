output "instance_public_ip_addr" {
  description = "Prints the public IP of the EC2 instance."
  value       = aws_instance.test_server.public_ip
}

output "s3_bucket_name" {
  description = "Prints the name of the s3 bucket."
  value       = aws_s3_bucket.test_bucket.id
}
