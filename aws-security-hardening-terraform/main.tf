provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.tags, {
      Environment = var.environment
      Project     = var.project_name
    })
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ---------------------------------------------------------------------------
# 1. IAM account password policy (CIS 1.5 - 1.11)
# ---------------------------------------------------------------------------
module "iam_password_policy" {
  source = "./modules/iam-password-policy"

  policy = var.iam_password_policy
}

# ---------------------------------------------------------------------------
# 2. Block public access at the account level (CIS 2.1.5)
# ---------------------------------------------------------------------------
module "s3_account_public_access_block" {
  source = "./modules/s3-account-public-access-block"
}

# ---------------------------------------------------------------------------
# 3. Multi-region CloudTrail with log file validation and encrypted storage
#    (CIS 3.1 - 3.7)
# ---------------------------------------------------------------------------
module "cloudtrail" {
  source = "./modules/cloudtrail"

  project_name        = var.project_name
  log_retention_days  = var.log_retention_days
  account_id          = data.aws_caller_identity.current.account_id
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# 4. GuardDuty threat detection (CIS 4.15 / Foundational Security Best
#    Practices)
# ---------------------------------------------------------------------------
module "guardduty" {
  source = "./modules/guardduty"
  count  = var.enable_guardduty ? 1 : 0
}

# ---------------------------------------------------------------------------
# 5. AWS Config for continuous configuration compliance recording
# ---------------------------------------------------------------------------
module "config" {
  source = "./modules/config"
  count  = var.enable_config ? 1 : 0

  project_name = var.project_name
  account_id   = data.aws_caller_identity.current.account_id
  tags         = var.tags
}

# ---------------------------------------------------------------------------
# 6. Security Hub with the CIS AWS Foundations Benchmark standard enabled
# ---------------------------------------------------------------------------
module "security_hub" {
  source = "./modules/security-hub"
  count  = var.enable_security_hub ? 1 : 0

  depends_on = [module.config]
}
