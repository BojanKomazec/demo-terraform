output "response_headers" {
  value = [for download in module.download_yaml_file: download.response_headers]
}

output "status_code" {
	value = [for download in module.download_yaml_file: download.status_code]
}

output "file_names" {
	value = local.file_names
}