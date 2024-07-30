resource "null_resource" "print_vars" {
	# This provisioner will be executed during apply phase
	provisioner "local-exec" {
		command = "echo '${local.full_name2}'"
	}
}