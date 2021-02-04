variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_profile" {
  type = string
  default = "default"
}

# VPC configuration
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "rest_api_address" {
  description = "The address from where we get the information"
}

variable "system_username" {
  description = "Username to authenticate in the REST api"
}

variable "system_password" {
  description = "Password to authenticate in the REST api"
  sensitive = true
}

variable "cache_pwd" {
  description = "Cache`s password"
  sensitive = true
}

variable "resource_prefix" {
  type = string
}
