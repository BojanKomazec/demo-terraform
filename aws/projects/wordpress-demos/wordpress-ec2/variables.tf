# If this variable is defined, this module will not create key pair but will be
# using the provided public key.
variable "public_key_path" {
  description = "Absolute path to the public key from the key pair generated outside Terraform. Pass this value as Terraform's command line argument."
  type        = string
  default     = null
}