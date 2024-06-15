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

resource "local_file" "foo" {
  filename = "${path.cwd}/temp/foo.txt"
  # filename = "${path.module}/temp/foo.txt"
  content = "This is a text content of the foo file!"

  # If we want to prevent 'terraform plan|apply' commands to print out the file content in their
  # output in terminal, we can use sensitive_content argument (instead of content):
  # sensitive_content = "This is a text content of the foo file!"
  # Execution plan in terminal will now contain this line:
  # + sensitive_content    = (sensitive value)

  # Uncomment and execute 'terraform apply' again in order to change resources already deployed
  # file_permission = "0700"
}

# use 'terraform output foo_files' after 'terraform apply'
output "foo_files" {
  value     = local_file.foo
  sensitive = true
}

# template_file data source renders a template from a template string, which is usually loaded from an external file
# (!) In Terraform 0.12 and later use the templatefile function instead.
#
# file() reads the contents of a file at the given path and returns them as a string.
data "template_file" "single-var-template" {
  # template = "${file("${path.module}/single_var_template.tpl")}"
  template = file("${path.module}/templates/single_var_template.tpl")
  vars = {
    my_var = "my_value"
  }
}

locals {
  rendered_template_path = "${path.module}/temp/rendered_template.txt"
}

resource "local_file" "rendered-template" {
  content  = data.template_file.single-var-template.rendered
  filename = local.rendered_template_path
}

# The primary use-case for the null resource is as a do-nothing container
# for arbitrary actions taken by a provisioner.
resource "null_resource" "run" {
  # Changes to rendered template file require re-printing it to output
  triggers = {
    file = "${data.template_file.single-var-template.rendered}"
  }

  provisioner "local-exec" {
    command = "cat ${local.rendered_template_path}"
  }
}