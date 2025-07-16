variable "db_name" {
  description = "The name of the database"
  type = string
  sensitive = true
}

variable "username" {
  description = "Username for the RDS database"
  type = string
  sensitive = true
}

variable "password" {
  description = "Password to the database"
  type = string
  sensitive = true
} 

variable "ami" {
  description = "Image for EC2 instance"
  type = string
  default = "ami-0d1b5a8c13042c939"
}

variable "instance_type" {
  description = "Type of instance"
  type = string
  default = "t2.micro"
}

variable "key_name" {
  description = "Name of key pair"
  type = string
  sensitive = true
}
