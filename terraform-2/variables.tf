variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_profile" {
  type = string
  default = "default"
}

# AWS Credential
variable "access_key" {
  description = "AWS Access Key"
  default = ""
}
variable "secret_key" {
  description = "AWS Secret Key"
  default = ""
}

# AWS Region and Availablility Zone
variable "region" {
  default = "us-east-1"
}

variable "availability_zone" {
  default = "us-east-1e"
}

# VPC configuration
variable "vpc_cidr_block" {
  default = "10.88.0.0/16"
}

variable "vpc_instance_tenancy" {
  default = "default"
}

variable "vpc_name" {
  default = "INFLUENCE_ANALYSIS VPC"
}

# Management subnet configuration
variable "mgmt_subnet_cidr_block" {
  default = "10.88.0.0/24"
}

# Untrusted subnet configuration
variable "untrusted_subnet_cidr_block" {
  default = "10.88.1.0/24"
}

# Trust subnet configuration
variable "trust_subnet_cidr_block" {
  default = "10.88.66.0/24"
}

# INFLUENCE_ANALYSIS configuration
variable "influence_analysis_payg_bun2_ami_id" {
  //    type = map
  default = {
    eu-west-1 = "ami-5d92132e",
    ap-southeast-1 = "ami-946da7f7",
    ap-southeast-2 = "ami-d7c6e5b4",
    ap-northeast-2 = "ami-fb08c195",
    eu-central-1 = "ami-8be001e4",
    ap-northeast-1 = "ami-b84b5ad6",
    us-east-1 = "ami-29a8a243",
    us-west-1 = "ami-12d0ad72",
    sa-east-1 = "ami-19810e75",
    us-west-2 = "ami-e4be4b84",
    us-east-2 = "ami-9ef3c5fb"
  }
}

variable "influence_analysis_byol_ami_id" {
  //    type = map
  default = {
    ap-south-1 = "ami-5c187233",
    eu-west-1 = "ami-73971600",
    ap-southeast-1 = "ami-0c60aa6f",
    ap-southeast-2 = "ami-f9c4e79a",
    ap-northeast-2 = "ami-fa08c194",
    eu-central-1 = "ami-74e5041b",
    ap-northeast-1 = "ami-e44b5a8a",
    us-east-1 = "ami-1daaa077",
    us-west-1 = "ami-acd7aacc",
    sa-east-1 = "ami-1d860971",
    us-west-2 = "ami-e7be4b87",
    us-east-2 = "ami-11e1d774"
  }

}

variable "influence_analysis_instance_type" {
  default = "c4.xlarge"
}

variable "influence_analysis_key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "panw-mlue"
}

variable "influence_analysis_key_path" {
  description = "Path to the private portion of the SSH key specified."
  default = "keys/panw-mlue.pem"
}

variable "influence_analysis_public_ip" {
  default = "true"
}

variable "influence_analysis_mgmt_private_ip" {
  default = "10.88.0.200"
}

variable "influence_analysis_untrusted_private_ip" {
  default = "10.88.1.210"
}

variable "influence_analysis_trust_private_ip" {
  default = "10.88.66.220"
}

variable influence_analysis_bootstrap_s3 {
  default = "influence_analysis-bootstrap-bucket"
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
