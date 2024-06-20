# There is no charge for an internet gateway, but there are data transfer
# charges for EC2 instances that use internet gateways.

# Our custom IGW is attached to our nondefault VPC.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.igw["tags"]["Name"]
  }
}