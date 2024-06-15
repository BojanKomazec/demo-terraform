#
# Public and private subnets will have their own routing table.
# Public subnets will use 'public' routing table which routes entire traffic to
# Internet Gateway.
# Private subnets will use 'private' routing table which routes entire traffic
# to NAT Gateway.
#
# Route Destination = cidr_block
# Route Target = gateway_id, nat_gateway_id
#

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main-non-default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main-non-default.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    Name = "private"
  }
}


resource "aws_route_table_association" "public-eu-west-2a" {
  subnet_id      = aws_subnet.public-eu-west-2a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-eu-west-2b" {
  subnet_id      = aws_subnet.public-eu-west-2b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-eu-west-2c" {
  subnet_id      = aws_subnet.public-eu-west-2c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-eu-west-2a" {
  subnet_id      = aws_subnet.private-eu-west-2a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-eu-west-2b" {
  subnet_id      = aws_subnet.private-eu-west-2b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-eu-west-2c" {
  subnet_id      = aws_subnet.private-eu-west-2c.id
  route_table_id = aws_route_table.private.id
}


