resource "local_file" "value" {

# If we define variable "filename" as tuple and use
#   for_each = var.filename
# then 'terraform plan' outputs:
#
# │ Error: Invalid for_each argument
# │
# │   on create_local_file.tf line 2, in resource "local_file" "value":
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
  filename = "${var.dest_dir_path}/value-${each.value}"

  content = "This is a text content of the value file!"
}

resource "local_file" "key" {
  for_each = toset(var.filename)
  filename = "${var.dest_dir_path}/key-${each.key}"
  content = "This is a text content of the key file!"
}

resource "local_file" "count" {
  # filename = "${path.cwd}/temp/foo.txt"

  # if we're using count meta-argument, we can use it's current value: count.index
  # filename = "${path.cwd}/temp/foo${count.index}.txt"

  # TF can read attribute values from variables file.
  # var.filename is a tuple with 3 elements and we can access them by using var.filename[i]:
  filename = "${var.dest_dir_path}/count-${var.filename[count.index]}"

  content = "This is a text content of the foo file!"

  # count = 3

  # Automatically pick up the length of the list:
  count = length(var.filename)
}
