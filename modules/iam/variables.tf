variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "Policy document for assuming the role"
  type        = string
}

variable "policy_attachments" {
  description = "Map of policy ARNs to attach to the IAM role"
  type        = list(string)
  default = []
}

variable "custom_policies" {
  description = "Map of custom IAM policies"
  type        = map(string)
  default = {}
}