locals {
    subnet_cidrs = {
        // for i, az in data.aws_availability_zones.available.names: az => i

        /*
        for i, az in data.aws_availability_zones.available.names: az => {
            cidr = cidrsubnet(var.vpc_cidr, 8, i)
        }*/

        for i, az in data.aws_availability_zones.available.names: az => {
            public = cidrsubnet(var.vpc_cidr, 8, i)
            private = cidrsubnet(var.vpc_cidr, 8, i + length(data.aws_availability_zones.available.names))
        }
    }
}

output "subnet_cidrs" {
    value = local.subnet_cidrs
}

output "azb_private_cidr" {
    value = local.subnet_cidrs[data.aws_availability_zones.available.names[1]].private
}

output "test_object_output" {
    value = { for k, v in local.subnet_cidrs: k => v }
}

output "test_object_tuple_keys" {
    value = [ for k, v in local.subnet_cidrs: k ]
}

output "test_object_tuple_values" {
    value = [ for k, v in local.subnet_cidrs: v ]
}

resource "local_file" "az" {
    for_each = local.subnet_cidrs

    filename = "${path.cwd}/temp/${each.key}"
    content = "Public: ${each.value.public}\nPrivate: ${each.value.private}"
}