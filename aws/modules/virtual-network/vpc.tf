# This is a placeholder file
# ToDo: Provision custom VPC and subnets

# Default VPC CIDR is 172.31.0.0/16.
# VPC CIDR needs to be withing the allowed range of private IP addresses:
# 10.0.0.0/8 IP addresses: 10.0.0.0 – 10.255.255.255
# 172.16.0.0/12 IP addresses: 172.16.0.0 – 172.31.255.255
# 192.168.0.0/16 IP addresses: 192.168.0.0 – 192.168.255.255
resource "aws_vpc" "this" {
  cidr_block = lookup(var.vpc, "cidr_block")

  # Required for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc["tags"]["Name"]

    # Ideally, parent module will use ${terraform.workspace}
    Environment = var.vpc["tags"]["Environment"]
  }
}