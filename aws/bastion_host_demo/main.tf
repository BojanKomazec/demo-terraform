resource "aws_vpc" "test-vpc" {
    cidr_block  = "10.10.0.0/16"
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

resource "aws_subnet" "public-subnet" {
    vpc_id     = aws_vpc.test-vpc.id
    cidr_block = "10.10.0.0/24"
    availability_zone = "eu-west-1a"

    // instances launched into the subnet should be assigned a public IP address
    map_public_ip_on_launch = true

    tags = {
        Name = "Public subnet"
    }
}

resource "aws_subnet" "private-subnet" {
    vpc_id     = aws_vpc.test-vpc.id
    cidr_block = "10.10.3.0/24"
    availability_zone = "eu-west-1a"

    tags = {
        Name = "Private subnet"
    }
}

resource "aws_route_table_association" "public-subnet-rt-association" {
    subnet_id      = aws_subnet.public-subnet.id
    route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-subnet-rt-association" {
    subnet_id      = aws_subnet.private-subnet.id
    route_table_id = aws_route_table.private-rt.id
}

resource "aws_instance" "bastion-host-ec2-instance" {
    availability_zone = "eu-west-1a"
    instance_type = "t2.micro"

    # Amazon Linux 2 (default user: ec2-user)
    ami = "ami-0c1bc246476a5572b"

    subnet_id = aws_subnet.public-subnet.id
    associate_public_ip_address = true

    tags = {
        Description = "Bastion host EC2"
        Name = "Bastion host EC2"
    }

    key_name = aws_key_pair.ec2--demo-app.key_name

    vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]

    depends_on = [aws_internet_gateway.int-gw]
}

resource "aws_instance" "private-ec2-instance" {
    availability_zone = "eu-west-1a"
    instance_type = "t2.micro"

    # Amazon Linux 2 (default user: ec2-user)
    ami = "ami-0c1bc246476a5572b"

    subnet_id = aws_subnet.private-subnet.id

    tags = {
        Description = "Private EC2"
        Name = "Private EC2"
    }

    key_name = aws_key_pair.ec2--demo-app.key_name

    vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
}

resource "aws_key_pair" "ec2--demo-app" {
    public_key = file("./keys/key-pair--ec2--demo-app.pub")
    key_name = "key-pair--ec2--demo-app"
}

// capture Bastion Host public IP so we can SSH to it from dev box
output bastion_host_ec2_ip {
    value = aws_instance.bastion-host-ec2-instance.public_ip
}

// capture Private Ec2 Host private IP so we can SSH to it from bastion host
output private_ec2_ip {
    value = aws_instance.private-ec2-instance.private_ip
}
