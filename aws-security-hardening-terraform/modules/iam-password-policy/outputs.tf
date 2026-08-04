output "policy_id" {
  description = "The account ID the password policy applies to."
  value       = aws_iam_account_password_policy.this.id
}
