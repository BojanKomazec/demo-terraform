# use 'terraform output value_files' after 'terraform apply'
output "value_files" {
  value     = local_file.value
  # sensitive = true
}

output "key_files" {
  value     = local_file.key
  # sensitive = true
}

# use 'terraform output count_files' after 'terraform apply'
output count_files {
  value = local_file.count
  sensitive = true
}

