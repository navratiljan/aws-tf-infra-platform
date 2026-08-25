terraform {
  required_version = "~> 1.15" # Always try to use the most up to date version of Terraform

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60.0" # Always try to use the most up to date version of the AWS provider
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0" # Always try to use the most up to date version of the Kubernetes provider
    }
  }
}
provider "aws" {
  region = var.region

  ignore_tags {
    key_prefixes = [""] # Ignore all tags since they are managed externally
  }

  # Set default tags for all resources
  default_tags {
    tags = local.tags
  }
}