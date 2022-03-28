# "resource" is the reserved word and is the block name
# "local_file" is also a reserved word and it denotes the type of the resource
#   local - resource provider
#   file - resource type
# "foo" - a logical resource name
# Inside the curly braces are arguments for resource. They are specific for the given resource type.
#
# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
# https://www.terraform.io/language/expressions/references#filesystem-and-workspace-info
resource "local_file" "foo" {
    filename = "${path.cwd}/temp/foo.txt"
    content = "This is a text content of the foo file!"
}