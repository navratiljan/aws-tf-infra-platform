variable "region" {
  description = "Location of resource group"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "name of the environment"
  type        = string
}

variable "project_name" {
  description = "name of the project"
  type        = string
}

variable "another_non_secret_variable" {
  description = "Dummy non-secret variable"
  type        = string
}

variable "enable_compute" {
  description = "Enable component"
  type        = bool
  default     = true
}

variable "ecs_app_config" {
  type    = map(any)
  default = {}
}

variable "s3_bucket_config" {
  type    = map(any)
  default = {}
}

variable "enable_eks" {
  description = "Enable EKS cluster"
  type        = bool
  default     = false
}

variable "enable_analytics" {
  description = "Enable analytics"
  type        = bool
  default     = false
}

variable "create_google_provider" {
  description = "Create Google identity provider"
  type        = bool
  default     = true
}

variable "google_client_id" {
  description = "Google client ID"
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Google client secret"
  type        = string
  default     = ""
}