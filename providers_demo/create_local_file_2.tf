resource "local_file" "file2" {
    filename = "${path.cwd}/temp/file2.txt"
    content = "This is a text content of the file2 file!"
}