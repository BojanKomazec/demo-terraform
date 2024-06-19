output "response_headers" {
	# using value = data.http.file[*].response_headers returns error:
	# Can't access attributes on a list of objects. Did you mean to access
	# attribute "response_headers" for a specific element of the list, or across
	# all elements of the list?
	value = [for http in data.http.file: http.response_headers]
}

output "status_code" {
	value = [for http in data.http.file: http.status_code]
}