output "cloudtrail_arn" {
  description = "ARN of the account's central CloudTrail trail."
  value       = module.cloudtrail.trail_arn
}

output "cloudtrail_log_bucket" {
  description = "S3 bucket storing CloudTrail logs."
  value       = module.cloudtrail.log_bucket_name
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID, if enabled."
  value       = var.enable_guardduty ? module.guardduty[0].detector_id : null
}

output "config_recorder_name" {
  description = "AWS Config recorder name, if enabled."
  value       = var.enable_config ? module.config[0].recorder_name : null
}

output "account_id" {
  description = "AWS account ID this baseline was applied to."
  value       = data.aws_caller_identity.current.account_id
}
