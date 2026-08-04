variable "project_name" {
  description = "Prefix used for naming CloudTrail resources."
  type        = string
}

variable "account_id" {
  description = "AWS account ID (used in bucket naming and policy scoping)."
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudTrail logs before expiration."
  type        = number
}

variable "tags" {
  description = "Tags applied to CloudTrail resources."
  type        = map(string)
  default     = {}
}
