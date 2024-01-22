locals {
  resource_prefix = "${var.project}-${var.env}"
  subnet_count    = length(var.availability_zones)
}

data "aws_region" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { "Name" = "${local.resource_prefix}-vpc" })
}

resource "aws_subnet" "private_subnet" {
  count             = local.subnet_count
  cidr_block        = "10.0.${count.index + 200}.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { "Name" = "${local.resource_prefix}-private-subnet-${count.index}" })
}

resource "aws_route_table" "private_subnet_route" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { "Name" = "${local.resource_prefix}-private-route" })
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = local.subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_subnet_route.id
}

resource "aws_subnet" "dmz_subnet" {
  count             = local.subnet_count
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { "Name" = "${local.resource_prefix}-dmz-subnet-${count.index}" })
}

resource "aws_route_table" "dmz_subnet_route" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { "Name" = "${local.resource_prefix}-dmz-route" })
}

resource "aws_route_table_association" "dmz_subnet_association" {
  count          = local.subnet_count
  subnet_id      = aws_subnet.dmz_subnet[count.index].id
  route_table_id = aws_route_table.dmz_subnet_route.id
}


resource "aws_subnet" "public_subnet" {
  count             = local.subnet_count
  cidr_block        = "10.0.${count.index + 100}.0/24"
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { "Name" = "${local.resource_prefix}-public-subnet-${count.index}" })
}

resource "aws_default_route_table" "public_subnet_route" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags                   = merge(var.tags, { "Name" = "${local.resource_prefix}-route" })
}

resource "aws_main_route_table_association" "main_route_table" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_default_route_table.public_subnet_route.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = local.subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_default_route_table.public_subnet_route.id
}

resource "aws_route" "dmz_subnet_ig_route" {
  route_table_id         = aws_default_route_table.public_subnet_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { "Name" = "${local.resource_prefix}-ig" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags          = merge(var.tags, { "Name" = "${local.resource_prefix}-nat" })
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.tags, { "Name" = "${local.resource_prefix}-nat" })
}

resource "aws_route" "dmz_subnet_nat_route" {
  route_table_id         = aws_route_table.dmz_subnet_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_vpc_endpoint" "s3" {
  count           = var.s3_vpc_gateway_endpoint ? 1 : 0
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = [aws_route_table.dmz_subnet_route.id]
  tags            = { "Name" = "${local.resource_prefix}-s3" }
}

resource "aws_vpc_endpoint" "dynamodb" {
  count           = var.dynamodb_vpc_gateway_endpoint ? 1 : 0
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  route_table_ids = [aws_route_table.dmz_subnet_route.id]
  tags            = { "Name" = "${local.resource_prefix}-dynamodb" }
}
