# Enforces an account-wide IAM password policy aligned with CIS AWS
# Foundations Benchmark controls 1.5 through 1.11.
#
# Why this matters: weak or reused local IAM passwords are one of the
# most common initial access vectors in AWS account compromises. This
# resource is account-global — there is only ever one policy per account.

resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.policy.minimum_password_length
  require_lowercase_characters   = var.policy.require_lowercase_characters
  require_uppercase_characters   = var.policy.require_uppercase_characters
  require_numbers                = var.policy.require_numbers
  require_symbols                = var.policy.require_symbols
  allow_users_to_change_password = var.policy.allow_users_to_change_password
  max_password_age               = var.policy.max_password_age
  password_reuse_prevention      = var.policy.password_reuse_prevention
}
