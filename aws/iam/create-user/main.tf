# https://registry.terraform.io/providers/hashicorp/aws/latest/docs#provider-configuration
# provider "aws" {
#     access_key = ""
#     secret_key = ""
#     region = ""
# }

resource "aws_iam_user" "admin_user" {
    name = "Adam"
    tags = {
        Description = "Technical Team Lead"
    }
}