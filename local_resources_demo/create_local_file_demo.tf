# "resource" is the reserved word and is the block name
# "local_file" is also a reserved word and it denotes the type of the resource
#   local - resource provider
#   file - resource type
# "foo" - a logical resource name
# Inside the curly braces are arguments for resource. They are specific for the given resource type.
#
# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
# https://www.terraform.io/language/expressions/references#filesystem-and-workspace-info
#
# Simple Terraform workflow:
# $ terraform init - initializes the working directory containing this .tf file
# $ terraform plan - to see and to review the execution plan
# $ terraform apply - to apply changes
# $ terraform show - to see the changes made
# $ terraform destroy - to destroy created resources
#

resource "local_file" "foo" {
  # filename = "${path.cwd}/temp/foo.txt"

  # if we're using count meta-argument, we can use it's current value: count.index
  # filename = "${path.cwd}/temp/foo${count.index}.txt"

  # TF can read attribute values from variables file.
  # var.filename is a tuple with 3 elements and we can access them by using var.filename[i]:
  filename = "${path.cwd}/temp/${var.filename[count.index]}"

  content = "This is a text content of the foo file!"

  # If we want to prevent 'terraform plan|apply' commands to print out the file content in their
  # output in terminal, we can use sensitive_content argument (instead of content):
  # sensitive_content = "This is a text content of the foo file!"
  # Execution plan in terminal will now contain this line:
  # + sensitive_content    = (sensitive value)

  # Uncomment and execute 'terraform apply' again in order to change resources already deployed
  # file_permission = "0700"

  # count = 3

  # Automatically pick up the length of the list:
  count = length(var.filename)
}