resource "aws_iam_user" "developer" {
    for_each = toset(split(":", var.cloud_users))
    name = "each.value"
}