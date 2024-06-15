# 'terraform plan' prints output vars

# Used for debugging
output "selected_vpc" {
  value = data.aws_vpc.selected
}

# Used for debugging
output "selected_subnets" {
  value = data.aws_subnets.selected
}

