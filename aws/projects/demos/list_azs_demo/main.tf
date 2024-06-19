// https://www.terraform.io/language/expressions/strings#indented-heredocs
// https://www.terraform.io/language/expressions/strings#directives
resource "local_file" "az_list" {
    filename = "${path.cwd}/temp/azs.txt"

    content = <<-EOT
        %{ for az in data.aws_availability_zones.available.names ~}
${az}
        %{ endfor ~}
    EOT
}

resource "local_file" "az" {
    # use this if var.filename has type set
    # for_each = var.filename

    # toset() converts list into set. Use it if var.filename is a list.
    for_each = toset(data.aws_availability_zones.available.names)

    filename = "${path.cwd}/temp/${each.value}"
    content = "This is a text content of the az file!"
}