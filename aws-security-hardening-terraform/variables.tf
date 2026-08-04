variable "aws_region" {
  description = "Primary AWS region for regional resources (CloudTrail is still enabled multi-region)."
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Environment tag applied to all resources (e.g. dev, staging, prod)."
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Short name used as a prefix for resource naming."
  type        = string
  default     = "security-baseline"
}

variable "log_retention_days" {
  description = "Retention period in days for CloudTrail / Config log buckets."
  type        = number
  default     = 365
}

variable "enable_guardduty" {
  description = "Whether to enable GuardDuty threat detection."
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Whether to enable Security Hub and the CIS AWS Foundations standard."
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Whether to enable AWS Config for continuous compliance recording."
  type        = bool
  default     = true
}

variable "iam_password_policy" {
  description = "Account-level IAM password policy, aligned to CIS AWS Foundations Benchmark 1.5-1.11."
  type = object({
    minimum_password_length        = number
    require_lowercase_characters   = bool
    require_uppercase_characters   = bool
    require_numbers                = bool
    require_symbols                = bool
    allow_users_to_change_password = bool
    max_password_age               = number
    password_reuse_prevention      = number
  })
  default = {
    minimum_password_length        = 14
    require_lowercase_characters   = true
    require_uppercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    allow_users_to_change_password = true
    max_password_age               = 90
    password_reuse_prevention      = 24
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Purpose   = "security-baseline"
  }
}
