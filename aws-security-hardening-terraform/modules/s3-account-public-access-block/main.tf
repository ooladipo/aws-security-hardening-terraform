# Account-level S3 Block Public Access (CIS 2.1.5).
#
# This is a "fail closed" guardrail: it prevents ANY S3 bucket in the
# account -- present or future -- from being made public via ACL or bucket
# policy, even if an individual engineer misconfigures a bucket later.
# It is one of the highest-leverage controls in this module because it
# protects against the single most common cause of AWS data breaches:
# accidentally public S3 buckets.

data "aws_caller_identity" "current" {}

resource "aws_s3_account_public_access_block" "this" {
  account_id = data.aws_caller_identity.current.account_id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
