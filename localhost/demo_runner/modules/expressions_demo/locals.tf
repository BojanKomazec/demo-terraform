#
# Terraform supports both a quoted syntax and a "heredoc" syntax for strings.
# Both of these syntaxes support template sequences for interpolating values and
# manipulating text.
#

locals {
	full_name = <<-DELIMITER
		${var.name}
		${var.surname}
	DELIMITER

	full_name2 = <<DELIMITER
	{
		Name = "Bojan"
		Surname = "Komazec"
	}
	DELIMITER
}