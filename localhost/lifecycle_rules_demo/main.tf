#
# Observe the output of the following sequence:
# prevent_destroy = true:
#   terraform init
#   terraform apply
#   modify file_permission
#   terraform apply
#

resource "local_file" "foo" {
    filename = "${path.cwd}/temp/foo.txt"
    # content = "This is a text content of the foo file!"

    # use the following sequence for test:
    # - with original value of content and ignore_changes set to content:
    #   terraform apply
    # - change the content to a new value
    #   terraform apply
    # This should return no changes in the output:
    #   No changes. Your infrastructure matches the configuration.
    #   Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
    #   Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
    content = "Use this to test ignore_changes rule"

    # file_permission = "0700"
    file_permission = "0777"

    lifecycle {
        # Create new resource before destroying the old one.
        # create_before_destroy = true

        # Don't destroy the previous resource.
        # Prevent any changes to take place that would 
        # result in destroying the existing resource.
        # prevent_destroy = true

        ignore_changes = [
            content, file_permission
        ]

        # To ignore changes in any attribute use the following syntax:
        # ignore_changes = all
    }
}