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