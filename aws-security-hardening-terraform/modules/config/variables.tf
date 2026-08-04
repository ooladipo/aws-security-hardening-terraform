variable "project_name" {
  description = "Prefix used for naming Config resources."
  type        = string
}

variable "account_id" {
  description = "AWS account ID (used in bucket naming and policy scoping)."
  type        = string
}

variable "tags" {
  description = "Tags applied to Config resources."
  type        = map(string)
  default     = {}
}
