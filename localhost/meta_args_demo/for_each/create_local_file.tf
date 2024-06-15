resource "local_file" "foo" {

# If we define variable "filename" as tuple and use
#   for_each = var.filename
# then 'terraform plan' outputs:
#
# │ Error: Invalid for_each argument
# │
# │   on create_local_file.tf line 2, in resource "local_file" "foo":
# │    2:   for_each = var.filename
# │     ├────────────────
# │     │ var.filename is tuple with 3 elements
# │
# │ The given "for_each" argument value is unsuitable: the "for_each" argument must be a map, or set of strings, and you have provided
# │ a value of type tuple.

  # Use this if var.filename is a set.
  # for_each = var.filename

  # toset() converts list into set. Use it if var.filename is a list.
  for_each = toset(var.filename)

  # TF can read attribute values from variables file.
  # We can access each via each.value:
  filename = "${path.cwd}/temp/${each.value}"

  content = "This is a text content of the foo file!"
}

# use 'terraform output foo_files' after 'terraform apply'
output "foo_files" {
  value     = local_file.foo
  sensitive = true
}