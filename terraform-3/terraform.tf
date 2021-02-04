terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region = var.aws_region
  max_retries = 1
}

# Create VPC
resource "aws_vpc" "influence-analysis-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  # needed to enable bootstrap and to resolve EIPs
  enable_dns_hostnames = false
  instance_tenancy = "default"
  tags = {
    Name = "influence-analysis-vpc"
  }
}

# Create two or more new subnets in your VPC. Public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  cidr_block = var.public_subnet_cidr_block
  //  availability_zone = var.availability_zone
  //  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Create two or more new subnets in your VPC. Private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  cidr_block = var.private_subnet_cidr_block
  //  availability_zone = var.availability_zone
  //  map_public_ip_on_launch = true
  tags = {
    Name = "private-subnet"
  }
}

# Create an internet gateway and attach it to your VPC.
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
}

# Create a NAT gateway. requires an EIP
resource "aws_eip" "nat-eip" {
  vpc = true
}

# Create a NAT gateway.
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.public-subnet.id
}

# Create and modify route tables for your subnets
# create two custom route tables for your VPC
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "private-route-table"
  }
}

# Associate the public subnet route table (Public Subnet) with the subnet that you want to make public.
resource "aws_route_table_association" "public-route-table-association" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

# Add a new route to the public route table.
resource "aws_route" "public-igw-route" {
  route_table_id = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gw.id
}

# Associate the other route table (Private Lambda) with the private subnets.
resource "aws_route_table_association" "private-route-table-association" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}

# Add a new route to the private route table.
resource "aws_route" "private-nat-gw-route" {
  route_table_id = aws_route_table.private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat-gw.id
}

# Configure network ACLs
# Create default VPC Network ACL
resource "aws_network_acl" "default-network-acl" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  egress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  ingress {
    protocol = "-1"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }
  tags = {
    Name = "default ACL"
  }
}

# TODO: Create ELASTICACHE
# Create ElastiCache Redis subnet group
resource "aws_elasticache_subnet_group" "default" {
  name = "subnet-group-redis"
  subnet_ids = [
    aws_subnet.private-subnet.id]
}

# Create ElastiCache Redis cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id = "redis-cluster"
  engine = "redis"
  node_type = "cache.t2.micro"
  num_cache_nodes = "1"
  parameter_group_name = "default.redis6.x"
  port = "6379"
  subnet_group_name = aws_elasticache_subnet_group.default.name
  security_group_ids = [
    aws_security_group.default-security-gp.id]
}

# Create a Lambda execution role for your VPC
resource "aws_iam_role" "influence-analysis-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sto-readonly-role-policy-attach" {
  role = aws_iam_role.influence-analysis-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Create default VPC security group
resource "aws_security_group" "default-security-gp" {
  name = "influence-analysis-allow-all"
  vpc_id = aws_vpc.influence-analysis-vpc.id
  description = "Allow all inbound traffic"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "influence-analysis-allow-all"
  }
}

# Configure your Lambda function
resource "aws_lambda_function" "influence-analysis-lambda" {
  function_name = "influence-analysis-lambda"
  handler = "br.com.palerique.influenceanalysis.lambda.Lambda"
  role = aws_iam_role.influence-analysis-role.arn
  runtime = "java11"

  filename = "${path.module}/../lambda/influence-analysis/lambda/build/distributions/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda/influence-analysis/lambda/build/distributions/lambda.zip")

  timeout = 60
  memory_size = 256

  vpc_config {
    security_group_ids = [
      aws_security_group.default-security-gp.id]
    subnet_ids = [
      aws_subnet.public-subnet.id,
      aws_subnet.private-subnet.id
    ]
  }

  environment {
    variables = {
      CACHE_HOST = aws_elasticache_cluster.redis.cache_nodes[0].address
      CACHE_PORT = aws_elasticache_cluster.redis.cache_nodes[0].port
      CACHE_PWD = var.cache_pwd
      SYSTEM_USERNAME = var.system_username
      SYSTEM_PWD = var.system_password
      REST_API_ADDRESS = "https://banzai-3006-1-1-10decb6-1.jivelandia.com/api/core/v3/analytics/influence/content/1009"
    }
  }
}
