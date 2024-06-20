#
# eu-west-2 region has 3 AZs. In each of them we want to create one public and
# one private subnet.
#
# Each subnet has Tier tag which can have value "Public" or "Private". This can 
# help later in filtering subnets e.g. filtering only private subnets.
#

#
# Public Subnets
#
# They will be assigned a 'public' routing table - the one which routes
# all traffic to Internet Gateway.
#
# Also, instances launched into these subnets will be assigned a public IP
# address. (AWS charges for these public IP addresses until instance is
# terminated and IP address is released)
#
#
# Private Subnets
#
# map_public_ip_on_launch default value is 'false'
#

resource "aws_subnet" "this" {
  for_each = { for idx, subnet in var.subnets : idx => subnet }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = merge(
    each.value.optional_tags, {
      Name        = each.value.tags["Name"]
      Tier        = each.value.tags["Tier"]
      Environment = each.value.tags["Environment"]
      Owner       = each.value.tags["Owner"]
    }
  )
}

