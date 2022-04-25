resource "local_file" "foo" {
    filename = "${path.cwd}/temp/foo.txt"
    content = "This is a text content of the file!"
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs
#
# 'terraform apply' output can be similar to:
#   local_file.foo: Creating...
#   local_file.foo: Creation complete after 0s [id=2579c708e91601fc83057a6004fbd5f5139d9f23]
#   random_pet.my_random_text: Creating...
#   random_pet.my_random_text: Creation complete after 0s [id=my_rnd_txt_.light.lobster]
#
resource "random_pet" "my_random_text" {
    # (Number) The length (in words) of the pet name
    length = 2

    # (String) A string to prefix the name with.
    prefix = "my_rnd_txt_"

    # (String) The character to separate words in the pet name.
    separator = "."
}