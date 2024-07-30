variable lambda_attributes {
  description = "List of Lambda Objects"
  type = list(object({
    name        = string
    description = string
    runtime     = string
  }))
  default = [
    {
      name        = "device-update",
      description = "device update function",
      runtime     = "nodejs20.x"
    },
    {
      name        = "location-update ",
      description = "location update function",
      runtime     = "nodejs20.x"
    },
    {
      name        = "ticket-update",
      description = "ticket update Function",
      runtime     = "nodejs20.x"
    }
  ]
}

resource "aws_iam_role" "role_for_lambda" {
  for_each = {for i, v in var.lambda_attributes:  i => v}
  name               = "iam_for_lambda_${each.value.name}"
  # assume_role_policy = data.aws_iam_policy_document.assume_role.json
	assume_role_policy = <<EOF
	EOF
}

resource "aws_lambda_function" "my_lambdas" {
  for_each = {for i, v in var.lambda_attributes:  i => v}
  function_name = "${each.value.name}"
  description   = "${each.value.description}"
  role          = aws_iam_role.role_for_lambda[i]
}

