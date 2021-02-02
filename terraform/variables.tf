variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_profile" {
  type = string
  default = "default"
}

variable "resource_prefix" {
  type = string
}

variable "log_level" {
  description = "Logging level"
  default = "Debug"
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

variable "instance_type" {
  default = "cache.t2.micro"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "cidrs" {
  default = {
    public = "10.0.1.0/24",
    private = "10.0.2.0/24",
    all = "0.0.0.0/0"
  }
}
