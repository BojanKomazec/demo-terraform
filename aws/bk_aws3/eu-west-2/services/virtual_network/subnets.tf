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

resource "aws_subnet" "public-eu-west-2a" {
  vpc_id                  = aws_vpc.main-non-default.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-eu-west-2a"
    Tier = "public"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/nginx-cluster" = "owned"
  }
}

resource "aws_subnet" "public-eu-west-2b" {
  vpc_id                  = aws_vpc.main-non-default.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-eu-west-2b"
    Tier = "public"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/nginx-cluster" = "owned"
  }
}

resource "aws_subnet" "public-eu-west-2c" {
  vpc_id                  = aws_vpc.main-non-default.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-eu-west-2c"
    Tier = "public"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/nginx-cluster" = "owned"
  }
}

#
# Private Subnets
#
# map_public_ip_on_launch default value is 'false'

resource "aws_subnet" "private-eu-west-2a" {
  vpc_id            = aws_vpc.main-non-default.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "private-eu-west-2a"
    Tier = "private"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/nginx-cluster" = "owned"
  }
}

resource "aws_subnet" "private-eu-west-2b" {
  vpc_id            = aws_vpc.main-non-default.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "private-eu-west-2b"
    Tier = "private"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/nginx-cluster" = "owned"
  }
}

resource "aws_subnet" "private-eu-west-2c" {
  vpc_id            = aws_vpc.main-non-default.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-west-2c"

  tags = {
    Name = "private-eu-west-2c"
    Tier = "private"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/nginx-cluster" = "owned"
  }
}