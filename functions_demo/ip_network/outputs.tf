output "subnets" {
    value = cidrsubnets("10.1.0.0/16", [for i in range(var.subnet_count) : "8"]...)
}