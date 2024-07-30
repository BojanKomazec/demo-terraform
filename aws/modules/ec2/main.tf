# get the ID of a registered AMI
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ami.name_pattern
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = var.ami.root_device_types
  }

  filter {
    name   = "virtualization-type"
    values = var.ami.virtualization_type
  }

  owners = var.ami.owners
}

resource "aws_instance" "this" {
  count                       = var.replicas
  ami                         = data.aws_ami.this.id
  instance_type               = var.ec2.instance_type
  key_name                    = var.key_pair_name
  security_groups             = ["${aws_security_group.this.id}"]
  associate_public_ip_address = true
  subnet_id                   = var.ec2.subnet_id
  tags                        = var.ec2.tags
}
