resource "aws_instance" "demo-app" {
    instance_type = "t2.micro"

    # Amazon Linux 2 (default user: ec2-user)
    # TODO: install Docker on it or find some AL2 AMI with Docker installed
    # Error: creating EC2 Instance: InvalidAMIID.NotFound: The image id '[ami-033b95fb8079dc481]' does not exist
    ami = "ami-0c1bc246476a5572b"

    tags = {
        Description = "EC2 AMI which runs demo application"
    }

    key_name = aws_key_pair.ec2--demo-app.key_name

    vpc_security_group_ids = [ aws_security_group.ssh-access.id ]
}

resource "aws_key_pair" "ec2--demo-app" {
    public_key = file("./keys/key-pair--ec2--demo-app.pub")
    key_name = "key-pair--ec2--demo-app"
}

resource "aws_security_group" "ssh-access" {
    name = "ssh-access"

    description = "Allows SSH connection from anywhere"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        # Outbound traffic is set to all
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

output ec2_ip {
    value = aws_instance.demo-app.public_ip
}
