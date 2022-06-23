resource "aws_vpc" "test-vpc" {
    cidr_block  = var.vpc_cidr

    tags = {
        Name = "test-vpc"
    }
}

// depends on VPC
resource "aws_internet_gateway" "int-gw" {
    vpc_id = aws_vpc.test-vpc.id

    tags = {
        Name = "Internet Gateway"
    }
}

// depends on VPC
resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow SSH inbound traffic"
    vpc_id      = aws_vpc.test-vpc.id

    ingress {
        description      = "SSH traffic"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
    }

    tags = {
        Name = "allow_ssh"
    }
}

// depends on: VPC (ID), Internet Gateway
// default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.
resource "aws_route_table" "public-rt" {
    vpc_id = aws_vpc.test-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.int-gw.id
    }

    tags = {
        Name = "Internet route table"
    }
}

// depends on VPC (ID)
// default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.
resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.test-vpc.id

    tags = {
        Name = "Local route table"
    }
}

locals {
    subnet_cidrs = {
        for i, az in data.aws_availability_zones.available.names: az => {
            public = cidrsubnet(var.vpc_cidr, 8, i)
            private = cidrsubnet(var.vpc_cidr, 8, i + length(data.aws_availability_zones.available.names))
        }
    }
}

resource "aws_subnet" "public-subnet" {
    vpc_id     = aws_vpc.test-vpc.id

    for_each = local.subnet_cidrs
    availability_zone = "${each.key}"
    cidr_block = "${each.value.public}"

    // instances launched into the subnet should be assigned a public IP address
    map_public_ip_on_launch = true

    tags = {
        Name = "Public subnet"
    }
}

resource "aws_subnet" "private-subnet" {
    vpc_id     = aws_vpc.test-vpc.id

    for_each = local.subnet_cidrs
    availability_zone = "${each.key}"
    cidr_block = "${each.value.private}"

    tags = {
        Name = "Private subnet"
    }
}

resource "aws_route_table_association" "public-subnet-rt-association" {
    for_each = local.subnet_cidrs
    subnet_id      = aws_subnet.public-subnet[each.key].id
    route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-subnet-rt-association" {
    for_each = local.subnet_cidrs
    subnet_id      = aws_subnet.private-subnet[each.key].id
    route_table_id = aws_route_table.private-rt.id
}

resource "aws_instance" "bastion-host-ec2-instance" {
    for_each = local.subnet_cidrs
    availability_zone = "${each.key}"
    instance_type = var.ec2_instance_type

    # Amazon Linux 2 (default user: ec2-user)
    // ami = "ami-0c1bc246476a5572b"
    ami = data.aws_ami.amzn2_ami.id

    subnet_id = aws_subnet.public-subnet[each.key].id
    associate_public_ip_address = true

    tags = {
        Description = "Bastion host EC2"
        Name = "Bastion host EC2"
    }

    // key_name = aws_key_pair.ec2--demo-app.key_name
    key_name = aws_key_pair.ec2-keypair.key_name

    vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]

    depends_on = [aws_internet_gateway.int-gw]
}

resource "aws_instance" "private-ec2-instance" {
    for_each = local.subnet_cidrs
    availability_zone = "${each.key}"
    instance_type = var.ec2_instance_type

    # Amazon Linux 2 (default user: ec2-user)
    ami = data.aws_ami.amzn2_ami.id

    subnet_id = aws_subnet.private-subnet[each.key].id

    tags = {
        Description = "Private EC2"
        Name = "Private EC2"
    }

    // key_name = aws_key_pair.ec2--demo-app.key_name
    key_name = aws_key_pair.ec2-keypair.key_name

    vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
}

# Use this in production
# resource "aws_key_pair" "ec2--demo-app" {
#     public_key = file("./keys/key-pair--ec2--demo-app.pub")
#     key_name = "key-pair--ec2--demo-app"
# }

resource "tls_private_key" "rsa-4096-private-key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "ec2-keypair" {
    key_name   = "ec2-keypair"
    public_key = tls_private_key.rsa-4096-private-key.public_key_openssh
}

resource "local_file" "ec2-key" {
    content  = tls_private_key.rsa-4096-private-key.private_key_pem
    filename = "${path.module}/temp/ec2-key"
}

