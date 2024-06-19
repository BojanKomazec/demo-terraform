data "aws_ami" "amzn2_ami" {
    // executable_users = ["self"]
    most_recent      = true
    // name_regex       = "^myami-\\d{3}"
    owners           = ["amazon"]
    // image_owner_alias = "amazon"

    filter {
        name   = "name"
        values = ["amzn2-ami-kernel-5.10-hvm-*"]
    }

    # filter {
    #     name   = "root-device-type"
    #     values = ["ebs"]
    # }

    # filter {
    #     name   = "virtualization-type"
    #     values = ["hvm"]
    # }
}
