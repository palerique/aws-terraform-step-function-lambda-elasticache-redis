# Configure the AWS Provider

# Create VPC
resource "aws_vpc" "influence-analysis-vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  # needed to enable bootstrap and to resolve EIPs
  enable_dns_hostnames = false
  instance_tenancy = var.vpc_instance_tenancy
  tags = {
    Name = var.vpc_name
  }
}

# Create Untrusted subnet
resource "aws_subnet" "untrusted-subnet" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  cidr_block = var.untrusted_subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "untrusted-subnet"
  }
}

# Create Trusted subnet
resource "aws_subnet" "trusted-subnet" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  cidr_block = var.trust_subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "trusted-subnet"
  }
}

# Create Untrusted route table
resource "aws_route_table" "untrusted-route-table" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "untrusted-route-table"
  }
}

# Create default route for Untrusted route table
resource "aws_route" "untrusted-default-route" {
  route_table_id = aws_route_table.untrusted-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  //  gateway_id = aws_internet_gateway.influence-analysis-igw.id
  //  gateway_id = aws_internet_gateway.nat-igw.id
  //TODO:
  gateway_id = aws_nat_gateway.gw.id
  depends_on = [
    aws_route_table.untrusted-route-table,
    //    aws_internet_gateway.influence-analysis-igw
    aws_internet_gateway.nat-igw
  ]
}

# Associate Untrusted route table to Untrusted subnet
resource "aws_route_table_association" "untrusted-route-table-association" {
  subnet_id = aws_subnet.untrusted-subnet.id
  route_table_id = aws_route_table.untrusted-route-table.id
}

# Create Trusted route table
resource "aws_route_table" "trusted-route-table" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "trusted-route-table"
  }
}

# Associate Trusted route table to Trusted subnet
resource "aws_route_table_association" "trusted-route-table-association" {
  subnet_id = aws_subnet.trusted-subnet.id
  route_table_id = aws_route_table.trusted-route-table.id
}

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
  subnet_ids = [
    //    aws_subnet.mgmt-subnet.id,
    aws_subnet.untrusted-subnet.id,
    aws_subnet.trusted-subnet.id
  ]
  tags = {
    Name = "default ACL"
  }
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

# Begin VPC NAT Gateway config
resource "aws_internet_gateway" "nat-igw" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "NAT Internet Gateway"
  }
}

resource "aws_subnet" "nat-subnet" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  cidr_block = "10.88.10.0/24"
  availability_zone = var.availability_zone
  tags = {
    Name = "nat-subnet"
  }
}

resource "aws_route_table" "nat-route-table" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "nat-route-table"
  }
}

resource "aws_route" "nat-route" {
  route_table_id = aws_route_table.nat-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.nat-igw.id
  depends_on = [
    aws_route_table.nat-route-table
  ]
}

resource "aws_route_table_association" "nat-route-table-association" {
  subnet_id = aws_subnet.nat-subnet.id
  route_table_id = aws_route_table.nat-route-table.id
}

resource "aws_eip" "nat-eip" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.nat-subnet.id
  depends_on = [
    aws_internet_gateway.nat-igw
  ]
}

############### Elasticache Redis
# Create ElastiCache Redis security group
resource "aws_security_group" "redis_sg" {
  vpc_id = aws_vpc.influence-analysis-vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"]
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    description = "elasticache ingress"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
    description = "elasticache egress"
  }
}

# Create ElastiCache Redis subnet group
resource "aws_elasticache_subnet_group" "default" {
  name = "subnet-group-redis"
  subnet_ids = [
    aws_subnet.trusted-subnet.id]
}

# Create ElastiCache Redis cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id = "redis-cluster"
  engine = "redis"
  node_type = var.instance_type
  num_cache_nodes = "1"
  parameter_group_name = "default.redis6.x"
  port = "6379"
  subnet_group_name = aws_elasticache_subnet_group.default.name
  security_group_ids = [
    aws_security_group.redis_sg.id]
}

# Create IAM role for Lambda function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"]
    }
  }
}

############### Lambda Role
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

resource "aws_iam_role_policy_attachment" "influence-analysis-role" {
  policy_arn = aws_iam_policy.influence-analysis-role.arn
  role = aws_iam_role.influence-analysis-role.name
}

resource "aws_iam_policy" "influence-analysis-role" {
  policy = data.aws_iam_policy_document.influence-analysis-role.json
}

data "aws_iam_policy_document" "influence-analysis-role" {
  statement {
    sid = "AllowInvokingLambdas"
    effect = "Allow"
    resources = [
      "arn:aws:lambda:us-east-1:*:function:*"]
    actions = [
      "lambda:InvokeFunction"]
  }

  statement {
    sid = "AllowCreatingLogGroups"
    effect = "Allow"
    resources = [
      "arn:aws:logs:us-east-1:*:*"]
    actions = [
      "logs:CreateLogGroup"]
  }

  statement {
    sid = "AllowWritingLogs"
    effect = "Allow"
    resources = [
      "arn:aws:logs:us-east-1:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid = "AllowIAMPassRole"
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "iam:*",
      "iam:PassRole",
      "organizations:DescribeAccount",
      "organizations:DescribeOrganization",
      "organizations:DescribeOrganizationalUnit",
      "organizations:DescribePolicy",
      "organizations:ListChildren",
      "organizations:ListParents",
      "organizations:ListPoliciesForTarget",
      "organizations:ListRoots",
      "organizations:ListPolicies",
      "organizations:ListTargetsForPolicy"
    ]
  }
}

# Attach an additional policy to Lambda function IAM role required for the VPC config
data "aws_iam_policy_document" "network" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "network" {
  //  count  = 1
  name = "influence-analysis-network"
  policy = data.aws_iam_policy_document.network.json
}

resource "aws_iam_policy_attachment" "network" {
  //  count      = 1
  name = "influence-analysis-network"
  roles = [
    aws_iam_role.influence-analysis-role.name]
  policy_arn = aws_iam_policy.network.arn
}

############### Lambda
resource "aws_lambda_function" "influence-analysis-lambda" {
  function_name = "${var.resource_prefix}-influence-analysis-lambda"
  handler = "br.com.palerique.influenceanalysis.lambda.Lambda"
  role = aws_iam_role.influence-analysis-role.arn
  runtime = local.runtime

  filename = local.lambda_jar_path
  source_code_hash = filebase64sha256(local.lambda_jar_path)

  timeout = 60
  memory_size = local.lambda_memory
  //  layers = [
  //    aws_lambda_layer_version.generic_stuff_layer.arn]

  vpc_config {
    subnet_ids = [
      aws_subnet.trusted-subnet.id,
      aws_subnet.untrusted-subnet.id,
      aws_subnet.nat-subnet.id
    ]
    security_group_ids = [
      aws_security_group.default-security-gp.id]
  }

  environment {
    variables = {
      LOG_LEVEL = var.log_level
      //      CACHE_HOST = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}"
      CACHE_HOST = aws_elasticache_cluster.redis.cache_nodes[0].address
      CACHE_PORT = aws_elasticache_cluster.redis.cache_nodes[0].port
      CACHE_PWD = var.cache_pwd
      SYSTEM_USERNAME = var.system_username
      SYSTEM_PWD = var.system_password
      REST_API_ADDRESS = var.rest_api_address
    }
  }
}

###############

# Output data
output "vpc-VPC-ID" {
  value = aws_vpc.influence-analysis-vpc.id
}

output "vpc-Default-Security-Group-ID" {
  value = aws_security_group.default-security-gp.id
}
