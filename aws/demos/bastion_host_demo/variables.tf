variable "vpc_cidr" {
    description = "VPC CIDR range"
    type = string
    default =  "10.10.0.0/16"
}

variable "ec2_instance_type" {
    description = "Chosen type of EC2 instances"
    type = string
    default = "t2.micro"
}