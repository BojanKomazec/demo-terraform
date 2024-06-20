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
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = { for idx, subnet in resource.aws_subnet.this : idx => subnet.id if resource.aws_subnet.this[idx].map_public_ip_on_launch == true}
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = { for idx, subnet in resource.aws_subnet.this : idx => subnet.id if resource.aws_subnet.this[idx].map_public_ip_on_launch == false}
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

