resource "aws_security_group" "this" {
  name = local.sg_name
  description = "Security group associated with EC2 instance"
  vpc_id      = var.vpc_id
  tags = {
    Name = local.sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "example" {
	for_each = var.security_group_ingress_rules

  security_group_id = aws_security_group.this.id

  cidr_ipv4   = each.value.cidr_ipv4
  from_port   = each.value.from_port
  ip_protocol = each.value.ip_protocol
  to_port     = each.value.to_port
}

resource "aws_vpc_security_group_egress_rule" "example" {
	for_each = var.security_group_egress_rules

  security_group_id = aws_security_group.example.id

  cidr_ipv4   = each.value.cidr_ipv4
  from_port   = each.value.from_port
  ip_protocol = each.value.ip_protocol
  to_port     = each.value.to_port
}

