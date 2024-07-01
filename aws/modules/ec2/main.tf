# get the ID of a registered AMI
data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = var.ami.name_pattern
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

resource "aws_security_group" "this" {
  name = "ec2-${var.ec2.tags.Name}-${var.environment}-sg"

  vpc_id = var.vpc_id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
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
