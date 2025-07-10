variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to launch"
  type        = string
}

variable "key_pair" {
  description = "The key pair name to associate with the instance"
  type        = string
}

variable "name" {
  description = "The Name tag for the instance"
  type        = string
}

variable "instance_profile_name" {
  description = "The name of the IAM instance profile to attach to the EC2 instance"
  type        = string
}
