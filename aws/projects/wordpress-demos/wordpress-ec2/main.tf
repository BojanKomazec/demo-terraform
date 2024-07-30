module "vpc" {
  source = "../../../modules/vpc"

  vpc = {
    cidr_block = local.vpc_cidr
    tags = {
      Name        = "${local.app_name}-vpc"
      Environment = local.env
    }
  }

  subnets = [{
    cidr_block = local.subnet_cidr
    # Create subnet in the first available availability zone
    availability_zone       = local.availability_zone_name
    map_public_ip_on_launch = true
    tags = {
      Name        = "${local.app_name}-public-subnet-${local.availability_zone_name}"
      Tier        = ""
      Environment = local.env
      Owner       = ""
    }
  }]

  igw = {
    tags = {
      Name = "${local.app_name}-igw"
    }
  }
}

# todo
# resource "aws_db_instance" "wordpress_db" {  (?)
# resource "aws_security_group" "wordpress_sg" {
# resource "aws_instance" "wordpress_instance" {

module "ec2" {
	source = "../../../modules/ec2"

	key_pair_name = "wordpress-ec2-keypair"
	public_key_path = var.public_key_path
	environment = "dev"
	vpc_id = module.vpc.vpc_id

	ec2 = {
		instance_type = "t2.micro"
		subnet_id = module.vpc.public_subnet_ids[0]
		tags = {
			Name = "wordpress-ec2"
			Environment = "dev"
		}
	}

	ami = {
		name_pattern = "al2023-ami-2023.*-x86_64"
		architecture = "x86_64"
	}

	security_group_ingress_rules = {
		"http" : {
			cidr_ipv4 = "10.0.0.0/8"
			from_port   = 80
			ip_protocol = "tcp"
			to_port = 80
		}
	}

	security_group_egress_rules = {
		"http" : {
			cidr_ipv4 = "10.0.0.0/8"
			from_port   = 80
			ip_protocol = "tcp"
			to_port = 80
		}
	}
}


