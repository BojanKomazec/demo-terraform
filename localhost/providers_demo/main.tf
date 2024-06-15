// Terraform configuration files can contain more than one resource block.

resource "local_file" "file3" {
    filename = "${path.cwd}/temp/file3.txt"
    content = "This is a text content of the file3 file!"
}

resource "local_file" "file4" {
    filename = "${path.cwd}/temp/file4.txt"
    content = "This is a text content of the file4 file!"
}