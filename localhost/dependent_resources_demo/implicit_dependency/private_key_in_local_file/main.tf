#
# Execute terraform init, plan, apply and destroy and observe outputs.
#

# Resource tls_private_key generates a secure private key and encodes it as PEM.
# It is a logical resource that lives only in the terraform state.
# Details of the resource, including the private key can be seeb by running the 'terraform show' command.
# https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
#
# terraform apply output snippet:
#
# Terraform will perform the following actions:
#
#   # tls_private_key.pvtkey will be created
#   + resource "tls_private_key" "pvtkey" {
#       + algorithm                     = "RSA"
#       + ecdsa_curve                   = "P224"
#       + id                            = (known after apply)
#       + private_key_openssh           = (sensitive value)
#       + private_key_pem               = (sensitive value)
#       + public_key_fingerprint_md5    = (known after apply)
#       + public_key_fingerprint_sha256 = (known after apply)
#       + public_key_openssh            = (known after apply)
#       + public_key_pem                = (known after apply)
#       + rsa_bits                      = 4096
#     }
#
resource "tls_private_key" "pvtkey" {
    algorithm="RSA"
    rsa_bits=4096
}

resource "local_file" "key_details" {
    filename="${path.cwd}/temp/key.txt"
    content=tls_private_key.pvtkey.private_key_pem
}