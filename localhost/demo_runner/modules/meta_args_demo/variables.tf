# var.filename is tuple with 3 elements
variable "filename" {
  # Use this in order to fix Error: Invalid for_each argument
  # type = set(string)

  type = list(string)

  default = [
    "foo.txt",
    "foo2.txt",
    "foo3.txt",
  ]
}

variable "dest_dir_path" {
  type = string
}
