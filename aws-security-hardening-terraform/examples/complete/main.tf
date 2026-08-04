module "aws_security_baseline" {
  source = "../../"

  aws_region   = "eu-central-1"
  environment  = "prod"
  project_name = "acme-corp"

  log_retention_days  = 365
  enable_guardduty    = true
  enable_security_hub = true
  enable_config       = true

  iam_password_policy = {
    minimum_password_length        = 14
    require_lowercase_characters   = true
    require_uppercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    allow_users_to_change_password = true
    max_password_age               = 90
    password_reuse_prevention      = 24
  }

  tags = {
    ManagedBy = "terraform"
    Team      = "security"
  }
}

output "cloudtrail_log_bucket" {
  value = module.aws_security_baseline.cloudtrail_log_bucket
}
