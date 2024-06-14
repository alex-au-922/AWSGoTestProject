resource "aws_vpc" "main" {
  cidr_block         = var.vpc_config.cidr
  enable_dns_support = true
  tags = {
    Name = "${var.vpc_config.name}-${var.env}"
  }
}

resource "aws_subnet" "public" {
  for_each          = { for subnet in var.vpc_config.subnets.public : subnet.az => subnet }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = {
    Name = "${var.vpc_config.name}-public-${split(each.key, "-")[2]}-${var.env}"
  }
}

resource "aws_subnet" "private" {
  for_each          = { for subnet in var.vpc_config.subnets.private : subnet.az => subnet }
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = {
    Name = "${var.vpc_config.name}-private-${split(each.key, "-")[2]}-${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = aws_subnet.public
    content {
      cidr_block = route.value.cidr_block
      gateway_id = aws_internet_gateway.igw.id
    }
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_network_acl_rule" "default_ingress" {
  for_each       = var.vpc_config.network_acls_ports.ingress
  network_acl_id = aws_network_acl.main.id
  protocol       = "tcp"
  rule_number    = (index(var.vpc_config.network_acls_ports.ingress, each.value) + 1) * 100
  egress         = false
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = each.value
  to_port        = each.value
}

resource "aws_network_acl_rule" "default_egress" {
  for_each = var.vpc_config.network_acls_ports.egress

  network_acl_id = aws_network_acl.main.id
  protocol       = "tcp"
  rule_number    = (index(var.vpc_config.network_acls_ports.egress, each.value) + 1) * 100
  egress         = true
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = each.value
  to_port        = each.value
}

resource "aws_network_acl_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.main.id
}

resource "aws_network_acl_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.main.id
}