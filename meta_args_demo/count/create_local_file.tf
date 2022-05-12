resource "local_file" "foo" {
  # filename = "${path.cwd}/temp/foo.txt"

  # if we're using count meta-argument, we can use it's current value: count.index
  # filename = "${path.cwd}/temp/foo${count.index}.txt"

  # TF can read attribute values from variables file.
  # var.filename is a tuple with 3 elements and we can access them by using var.filename[i]:
  filename = "${path.cwd}/temp/${var.filename[count.index]}"

  content = "This is a text content of the foo file!"

  # count = 3

  # Automatically pick up the length of the list:
  count = length(var.filename)
}

# use 'terraform output foo_files' after 'terraform apply'
output foo_files {
  value = local_file.foo
  sensitive = true
}