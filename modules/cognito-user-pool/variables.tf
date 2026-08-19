variable "create_google_provider" {
  description = "Create Google identity provider"
  type        = bool
  default     = true
}

variable "frontend_url" {
  description = "Frontend URL"
  type        = string

  
}
variable "google_client_id" {
  description = "Google client ID"
  type        = string
}

variable "google_client_secret" {
  description = "Google client secret"
  type        = string
}