variable "vpc" {
  description = "VPC configuration"
  type = object({
    cidr_block = string
    tags = object({
      Name        = string
      Environment = string
    })
  })
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    cidr_block              = string
    availability_zone       = string
    map_public_ip_on_launch = bool
    tags = object({
      Name        = string
      Tier        = string
      Environment = string
      Owner       = string
    })
    optional_tags = optional(map(string))
  }))
}

variable "igw" {
  description = "Internet Gateway properties"
  type = object({
    tags = object({
      Name = string
    })
  })
}

variable "nat_gw" {
  description = "NAT properties"
  type = object({
    # subnet_id = string
    tags = object({
      Name = string
    })
  })
}

