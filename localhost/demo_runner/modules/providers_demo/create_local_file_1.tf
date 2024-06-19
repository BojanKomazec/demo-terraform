resource "local_file" "file1" {
    filename = "${path.cwd}/temp/file1.txt"
    content = "This is a text content of the file1 file!"
}