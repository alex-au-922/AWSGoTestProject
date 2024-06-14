resource "aws_vpc" "main" {
  cidr_block         = var.vpc_config.cidr
  enable_dns_support = true
}

resource "aws_subnet" "public" {
  for_each          = { for subnet in var.vpc_config.subnets.public : subnet.az => subnet }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
}

resource "aws_subnet" "private" {
  for_each          = { for subnet in var.vpc_config.subnets.private : subnet.az => subnet }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = aws_subnet.public
    content {
      cidr_block = each.value.cidr_block
      gateway_id = aws_internet_gateway.igw.id
    }
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}