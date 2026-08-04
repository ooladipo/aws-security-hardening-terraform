output "recorder_name" {
  description = "Name of the AWS Config configuration recorder."
  value       = aws_config_configuration_recorder.this.name
}

output "config_bucket" {
  description = "S3 bucket storing AWS Config history."
  value       = aws_s3_bucket.config_logs.id
}
