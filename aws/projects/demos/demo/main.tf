resource "random_string" "random" {
  length = 8
}

resource "aws_iam_role" "backup_operator" {
  name = "test_role_${resource.random_string.random.result}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_backup_vault" "central_backup_vault" {
  name = "test_backup_vault"
}

resource "aws_organizations_policy" "backup_policy" {
  name        = "organization_backup_policy"
  description = "Organization wide backup policy"
  type        = "BACKUP_POLICY"

  # Neither 'terraform validate' or 'terraform plan' validate JSON or whether policy format meets required syntax.
  # Errors in policy will show only in 'terraform apply' e.g. HTTP error 400, MalformedPolicyDocumentException.
  # Use jsonencode in template itself.
  # https://developer.hashicorp.com/terraform/language/functions/templatefile#generating-json-or-yaml-from-a-template
  content = templatefile("${path.module}/policies/backup-policy.json.tftpl", {
    vault_name                = aws_backup_vault.central_backup_vault.name
    backup_operator_role_name = aws_iam_role.backup_operator.name
    backup_tag_key            = "Backup"
    backup_tag_value          = "true"
  })
}

# terraform output -raw backup_policy_content
# still shows escape characters.
# $ terraform output backup_policy_content | jq "fromjson"
# $ terraform output -raw backup_policy_content | jq "fromjson"
output "backup_policy_content" {
  value = aws_organizations_policy.backup_policy.content
}