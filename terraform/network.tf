resource "aws_vpc" "influence-vpc" {
  cidr_block = var.vpc_cidr
  tags = local.tags
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "influence_internet_gw" {
  vpc_id = aws_vpc.influence-vpc.id
}

# Grant the VPC internet access on its main route table
//resource "aws_route" "internet_access_route" {
//  route_table_id = aws_vpc.influence-vpc.main_route_table_id
//  destination_cidr_block = var.cidrs.public
//  gateway_id = aws_internet_gateway.influence_internet_gw.id
//}
resource "aws_route_table" "internet_access_route_table" {
  vpc_id = aws_vpc.influence-vpc.id
  route {
    cidr_block = var.cidrs.all
    gateway_id = aws_internet_gateway.influence_internet_gw.id
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "influence_public_sb" {
  vpc_id = aws_vpc.influence-vpc.id
  cidr_block = var.cidrs.public
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "influence_private_sb" {
  vpc_id = aws_vpc.influence-vpc.id
  cidr_block = var.cidrs.private
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[1]
}

# Create ElastiCache Redis subnet group
resource "aws_elasticache_subnet_group" "default" {
  name = "subnet-group-redis"
  subnet_ids = [
    aws_subnet.influence_private_sb.id]
}
