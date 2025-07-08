variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "DevOpsTestServer"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
  default     = "terraform-proj-628"
}
