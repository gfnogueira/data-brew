variable "role_name" {
  description = "The name of the IAM role."
}

variable "account_id" {
  description = "The AWS account ID."
}

variable "dlm_role_arn" {
  description = "The ARN of the AWS DLM role."
}

variable "allow_resources_actions" {
  description = "List of actions allowed by the IAM policy."
  type        = list(string)
}

variable "deny_resources_actions" {
  description = "List of actions denyed by the IAM policy."
  type        = list(string)
}

variable "dlm_resources_actions" {
  description = "List of actions for DLM resources in the IAM policy."
  type        = list(string)
}