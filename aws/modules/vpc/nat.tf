# Public NAT Gateway:
# - used by instances in private subnets so they can reach Internet
#   but prevents the Internet from initiating a connection directly to the instances.
# - must be created in a public subnet (so its traffic can be routed to Internet Gateway);
#   that's why this NAT is called a 'public'
# - has to have Elastic IP Address (public IPv4 address) attached to it

# Elastic IP
resource "aws_eip" "public_nat" {

  # Indicates if this EIP is for use in VPC
  domain = "vpc"
  tags = {
    Name = "public_nat"
  }
}

resource "aws_nat_gateway" "public" {
  allocation_id = aws_eip.public_nat.id

  # arbitrary selected public subnet
  # aws_subnet.public-eu-west-2a.id
  # TODO: var.nat_gw["subnet_id"]
  subnet_id = ([
    for index, subnet in resource.aws_subnet.this :
    resource.aws_subnet.this[index].id
    if resource.aws_subnet.this[index]["map_public_ip_on_launch"] == true
  ][0])

  tags = {
    Name = var.nat_gw["tags"]["Name"]
  }

  # NAT Gateway's traffic is routed to Internet via Internet Gateway
  depends_on = [aws_internet_gateway.this]
}