variable "key_pair_name" {
  description = "Name of the key pair used to access EC2 instance"
  type        = string
  default     = null
}

# If this variable is defined, this module will not create key pair but will be
# using the provided public key.
variable "public_key_path" {
  description = "Path to the public key from the key pair generated outside Terraform"
  type        = string
  default     = null
}

# This variable is ignored if public_key_path is defined (non-null).
variable "private_key_path" {
  description = "Path where to save the private key from the key pair generated by Terraform"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment e.g. dev, stage, beta, prod"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC in which EC2 instance will be provisioned"
  type        = string
}

variable "ec2" {
  description = "Specification of the EC2 instance"
  type = object({
    # e.g. "t4g.nano"
    instance_type = string
    subnet_id     = string
    tags = object({
      Name        = string
      Environment = string
      Tier        = optional(string)
      Owner       = optional(string)
    })
  })
}

variable "replicas" {
  description = "Number of EC2 instances to be created"
  type        = number
  default     = 1
}

variable "ami" {
  description = "Specification of the AMI to be used when creating EC2"
  type = object({
    # ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    name_pattern        = list(string)
    root_device_types   = optional(list(string), ["ebs"])
    virtualization_type = optional(list(string), ["hvm"])
    owners              = optional(list(string), ["aws"])
  })
}