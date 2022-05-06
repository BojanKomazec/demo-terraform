#
# Practice run:
#   terraform fmt
#   terraform init
#   terraform validate
#

resource "local_file" "key_data" {
  filename        = "/tmp/.pki/private_key.pem"
  content         = tls_private_key.private_key.private_key_pem
  file_permission = "0400"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"

  # Try running 'terraform validate' with this attribute name in place:
  # dsa_bits  = 4096
  rsa_bits  = 4096
}

resource "tls_cert_request" "csr" {
# $ terraform validate
# ╷
# │ Warning: Argument is deprecated
# │ 
# │   with tls_cert_request.csr,
# │   on main.tf line 23, in resource "tls_cert_request" "csr":
# │   23:   key_algorithm   = "ECDSA"
# │ 
# │ This is now ignored, as the key algorithm is inferred from the `private_key_pem`.

#   key_algorithm   = "ECDSA"

# $ terraform validate
# ╷
# │ Error: Invalid function argument
# │ 
# │   on main.tf line 21, in resource "tls_cert_request" "csr":
# │   21:   private_key_pem = file("/tmp/.pki/private_key.pem")
# │ 
# │ Invalid value for "path" parameter: no file exists at "/tmp/.pki/private_key.pem"; this function works only with files that are
# │ distributed as part of the configuration source code, so if this file will be created by a resource in this configuration you must
# │ instead obtain this result from an attribute of that resource.

  # private_key_pem = file("/tmp/.pki/private_key.pem")
  private_key_pem = local_file.key_data.content
  depends_on      = [local_file.key_data]

  subject {
    common_name  = "flexit.com"
    organization = "FlexIT Consulting Services"
  }
}