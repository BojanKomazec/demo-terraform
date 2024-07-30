locals {
  create_key_pair = var.public_key_path == null ? true : false
	sg_name = "ec2-${var.ec2.tags.Name}-${var.environment}-sg"
}