output "security_hub_id" {
  description = "ID of the Security Hub account subscription."
  value       = aws_securityhub_account.this.id
}
