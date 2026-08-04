# Enables Security Hub and subscribes the account to the CIS AWS
# Foundations Benchmark standard, giving a single aggregated, scored
# compliance dashboard across GuardDuty, Config, Inspector, and Security
# Hub's own checks. This is the control an auditor or hiring manager
# would expect to see tying the rest of the module together: individual
# services generate findings, Security Hub aggregates and prioritizes
# them.

resource "aws_securityhub_account" "this" {}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.4.0"
  depends_on    = [aws_securityhub_account.this]
}
