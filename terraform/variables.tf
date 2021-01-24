variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "resource_prefix" {
  type = string
}

variable "log_level" {
  description = "Logging level"
  default     = "Debug"
}

variable "instance_type" {
  default = "cache.t2.micro"
}

//variable "function_name" {
//  type = string
//}
//
//variable "attach_vpc_config" {
//  default = false
//}
//
//# tags
//variable "tag_name" {
//  type = string
//}
//
//variable "tag_contact-email" {
//  type = string
//}
//
//variable "cluster_id" {
//  type = string
//}
//
//variable "vpc_id" {
//  type = string
//}
//
//variable "private_subnet_ids" {
//  type = string
//}
//
//variable "private_subnet_cidrs" {
//  type = string
//}
//
//variable "engine_version" {
//  type = string
//}
//
//variable "parameter_group_name" {
//  type = string
//}
