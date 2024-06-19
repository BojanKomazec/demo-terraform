# $ terraform apply -var=length=6 -auto-approve
# $ terraform output password
# $ terraform apply -var=length=10 -auto-approve
# $ terraform output password

resource "random_password" "pwd-generator" {
	length = var.length < 8 ? 8 : var.length
}

output password {
	value = random_password.pwd-generator.result
    sensitive = true
}

variable length {
	type = number
}
