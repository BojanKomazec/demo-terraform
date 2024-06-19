data "http" "file" {
  url = var.file.url

  # Optional request headers
  request_headers = {
    Accept = "application/${var.file.type}"
  }

  lifecycle {
		# Terraform checks a precondition before evaluating the object it is
		# associated with and checks a postcondition after evaluating the object.
    postcondition {
			# condition argument. This is an expression that must return true if the
			# conditition is fufilled or false if it is invalid.
      condition     = contains([200], self.status_code)

			# If the condition evaluates to false, Terraform will produce an error
			# message
      error_message = "Status code invalid"
    }
  }
}

resource "local_file" "this" {
    content  = data.http.file.response_body
    filename = var.file.path
}

