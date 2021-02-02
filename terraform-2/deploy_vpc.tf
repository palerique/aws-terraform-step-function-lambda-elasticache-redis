# Configure the AWS Provider
//provider "aws" {
//  access_key = var.access_key
//  secret_key = var.secret_key
//  region = var.region
//}

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

# Create Management subnet
//resource "aws_subnet" "mgmt-subnet" {
//  vpc_id = aws_vpc.influence-analysis-vpc.id
//  cidr_block = var.mgmt_subnet_cidr_block
//  availability_zone = var.availability_zone
//  map_public_ip_on_launch = false
//  tags = {
//    Name = "mgmt-subnet"
//  }
//}

# Create Untrust subnet
resource "aws_subnet" "untrust-subnet" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  cidr_block = var.untrust_subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "untrust-subnet"
  }
}

# Create Trust subnet
resource "aws_subnet" "trust-subnet" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  cidr_block = var.trust_subnet_cidr_block
  availability_zone = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "trust-subnet"
  }
}

/* */
# Create VPC Internet Gateway
//resource "aws_internet_gateway" "influence-analysis-igw" {
//  vpc_id = aws_vpc.influence-analysis-vpc.id
//  tags = {
//    Name = "influence-analysis-igw"
//  }
//}

//# Create Management route table
//resource "aws_route_table" "mgmt-routetable" {
//  vpc_id = aws_vpc.influence-analysis-vpc.id
//  tags = {
//    Name = "mgmt-routetable"
//  }
//}
//
///* */
//# Create default route for Management route table
//resource "aws_route" "mgmt-default-route" {
//  route_table_id = aws_route_table.mgmt-routetable.id
//  destination_cidr_block = "0.0.0.0/0"
//  gateway_id = aws_internet_gateway.influence-analysis-igw.id
//  depends_on = [
//    "aws_route_table.mgmt-routetable",
//    "aws_internet_gateway.influence-analysis-igw"
//  ]
//}
//
//# Associate Management route table to Management subnet
//resource "aws_route_table_association" "mgmt-routetable-association" {
//  subnet_id = aws_subnet.mgmt-subnet.id
//  route_table_id = aws_route_table.mgmt-routetable.id
//}

# Create Untrust route table
resource "aws_route_table" "untrust-routetable" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "untrust-routetable"
  }
}

/* */
# Create default route for Untrust route table
resource "aws_route" "untrust-default-route" {
  route_table_id = aws_route_table.untrust-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  //  gateway_id = aws_internet_gateway.influence-analysis-igw.id
  gateway_id = aws_internet_gateway.nat-igw.id
  depends_on = [
    aws_route_table.untrust-routetable,
    //    aws_internet_gateway.influence-analysis-igw
    aws_internet_gateway.nat-igw
  ]
}

# Associate Untrust route table to Untrust subnet
resource "aws_route_table_association" "untrust-routetable-association" {
  subnet_id = aws_subnet.untrust-subnet.id
  route_table_id = aws_route_table.untrust-routetable.id
}

# Create Trust route table
resource "aws_route_table" "trust-routetable" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "trust-routetable"
  }
}

# Associate Trust route table to Trust subnet
resource "aws_route_table_association" "trust-routetable-association" {
  subnet_id = aws_subnet.trust-subnet.id
  route_table_id = aws_route_table.trust-routetable.id
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
    aws_subnet.untrust-subnet.id,
    aws_subnet.trust-subnet.id
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

//# Create an endpoint for S3 bucket
///*  Uncomment to enable */
//resource "aws_vpc_endpoint" "private-s3" {
//  vpc_id = aws_vpc.influence-analysis-vpc.id
//  service_name = "com.amazonaws.us-east-2.s3"
//  route_table_ids = [
//    aws_route_table.mgmt-routetable.id
//    #"${aws_route_table.trust-routetable.id}"
//  ]
//}

# Create a VPC NAT Gateway
# We need to create a public subnet for the NAT gateway to reside in
# We need to create an Internet Gateway for the NAT gateway to send internet traffic out
# The NAT gateway also requires an EIP
# We are adding a default route to the Nat route table to route traffic through Internet Gateway
# We are adding a default route to the Management route table to route internet traffic through NAT GW
///* Uncomment to enable
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

resource "aws_route_table" "nat-routetable" {
  vpc_id = aws_vpc.influence-analysis-vpc.id
  tags = {
    Name = "nat-routetable"
  }
}

resource "aws_route" "nat-route" {
  route_table_id = aws_route_table.nat-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.nat-igw.id
  depends_on = [
    aws_route_table.nat-routetable
  ]
}

resource "aws_route_table_association" "nat-routetable-association" {
  subnet_id = aws_subnet.nat-subnet.id
  route_table_id = aws_route_table.nat-routetable.id
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

//resource "aws_route" "gw-route" {
//  route_table_id = aws_route_table.mgmt-routetable.id
//  destination_cidr_block = "0.0.0.0/0"
//  nat_gateway_id = aws_nat_gateway.gw.id
//}
# End VPC NAT Gateway config
//*/

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
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

# Create ElastiCache Redis subnet group
resource "aws_elasticache_subnet_group" "default" {
  name = "subnet-group-redis"
  subnet_ids = [
    aws_subnet.trust-subnet.id]
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

//# Create Lambda function
//resource "null_resource" "lambda_function" {
//  provisioner "local-exec" {
//    command = "pwd"
//  }
//}

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

//resource "aws_iam_role" "lambda-vpc-role" {
//  name               = var.function_name
//  assume_role_policy = data.aws_iam_policy_document.assume_role.json
//}

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
resource "aws_lambda_function" "influenceAnalysisLambda" {
  function_name = "${var.resource_prefix}-influenceAnalysisLambda"
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
      aws_subnet.trust-subnet.id,
      aws_subnet.untrust-subnet.id,
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

//output "subnet-Management-Subnet-ID" {
//  value = aws_subnet.mgmt-subnet.id
//}

output "vpc-Default-Security-Group-ID" {
  value = aws_security_group.default-security-gp.id
}
