resource "aws_vpc" "influence-vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = local.tags
}