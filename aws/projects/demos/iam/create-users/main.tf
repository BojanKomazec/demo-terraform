resource "aws_iam_user" "users" {
    name = "${var.project-ruby-users[count.index]}"
    tags = {
        Description = "common user"
    }
    count = length(var.project-ruby-users)
}