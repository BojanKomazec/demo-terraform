resource "local_file" "foo" {
    filename = "${path.cwd}/temp/foo.txt"
    content = data.local_file.my_data_source.content
}

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file
data "local_file" "my_data_source" {
    filename = "${path.cwd}/data_source.txt"
}