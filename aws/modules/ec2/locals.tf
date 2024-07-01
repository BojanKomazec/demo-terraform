locals {
  create_key_pair = var.public_key_path == null ? true : false
}