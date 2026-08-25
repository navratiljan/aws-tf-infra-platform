variable "etl-name" {
  type        = string
  description = "Name prefix for Glue resources"
}

variable "s3_path_crawler" {
  type        = string
  description = "S3 path for Glue crawler"
}

variable "s3_scripts_bucket_name" {
  type        = string
  description = "Name of S3 bucket for storing Glue scripts"
}

variable "glue_src_path" {
  type        = string
  description = "Local path to Glue script source"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to Glue resources"
}

variable "crawler_schedule" {
  type        = string
  description = "Crawler schedule"
}

variable "glue_dst_path" {
  type        = string
  description = "Destination path for Glue scripts"
}

variable "iam_role_arn_etl" {
  type        = string
  description = "ARN of IAM role for Glue ETL job"
}

variable "iam_role_arn_crawler" {
  type        = string
  description = "ARN of IAM role for Glue crawler"
}

variable "data_tier" {
  type        = string
  description = "Data tier for Glue job"
}