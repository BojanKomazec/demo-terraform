# https://registry.terraform.io/providers/hashicorp/aws/latest/docs#provider-configuration
provider "aws" {
    # access_key = ""
    # secret_key = ""
    # region = ""

    # The following attributes are not needed when working directly with the AWS Cloud.
    # They are only needed when using an AWS mock framework.
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    endpoints {
      iam = "http://aws:4566"
    }
}