// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "available" {
    state = "available"
}

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