output "trail_arn" {
  description = "ARN of the CloudTrail trail."
  value       = aws_cloudtrail.this.arn
}

output "log_bucket_name" {
  description = "Name of the S3 bucket storing CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt CloudTrail logs."
  value       = aws_kms_key.cloudtrail.arn
}
