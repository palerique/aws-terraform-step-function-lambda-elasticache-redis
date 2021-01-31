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
}

variable "cache_pwd" {
  description = "Cache`s password"
}

variable "instance_type" {
  default = "cache.t2.micro"
}
