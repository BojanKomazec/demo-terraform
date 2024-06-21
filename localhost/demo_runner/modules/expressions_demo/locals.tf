locals {
	full_name = <<-DELIMITER
		${var.name}
		${var.surname}
	DELIMITER
}