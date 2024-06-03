# 'terraform plan' prints output vars

# Used for debugging
output "default_vpc" {
  value = data.aws_vpc.default
}

# Used for debugging
output "default_subnets" {
  value = data.aws_subnets.default
}