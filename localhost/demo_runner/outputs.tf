output "response_headers" {
  value = [for download in module.download_yaml_file: download.response_headers]
}

output "status_code" {
	value = [for download in module.download_yaml_file: download.status_code]
}

output "file_names" {
	value = local.file_names
}

output "yaml_template_file_content" {
	value = local.yaml_template_file_content
}

output "person_name" {
	value = local.person_name
}

output "person_name_2" {
	value = local.person_name_2
}

output "expressions_demo_full_name" {
	value = module.expressions_demo.0.full_name
}