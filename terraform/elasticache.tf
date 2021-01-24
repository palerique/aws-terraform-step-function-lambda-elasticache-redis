# Create ElastiCache Redis security group
resource "aws_security_group" "redis_sg" {
  vpc_id = aws_vpc.influence-vpc.id

  ingress {
    cidr_blocks = [
      aws_vpc.influence-vpc.cidr_block]
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_subnet" "redis_subnet" {
  vpc_id            = aws_vpc.influence-vpc.id
  cidr_block        = aws_vpc.influence-vpc.cidr_block
  availability_zone = "${var.aws_region}a"
}

# Create ElastiCache Redis subnet group
resource "aws_elasticache_subnet_group" "default" {
  name       = "subnet-group-redis"
  subnet_ids = [
    aws_subnet.redis_subnet.id]
}

# Create ElastiCache Redis cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = var.instance_type
  num_cache_nodes      = "1"
  parameter_group_name = "default.redis6.x"
  port                 = "6379"
  subnet_group_name    = aws_elasticache_subnet_group.default.name
  security_group_ids   = [
    aws_security_group.redis_sg.id]
}

# Create IAM role for Lambda function
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com"]
    }
  }
}

# Create Lambda function
resource "null_resource" "lambda_function" {
  provisioner "local-exec" {
    command = "pwd"
  }
}
