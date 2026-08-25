#TODO dedicated provider in one account
### SSM Secure strings ###
# These are usually static secret values that don't need to be rotated and don't have a lifecycle
# data "aws_ssm_parameter" "example_secret" {
#   name = "/${var.project_name}/${var.environment}/example-secret"
# }
data "aws_ssm_parameter" "google_client_id" {
  name = "${local.ssm_project_base_path}/google_client_id"
}

data "aws_ssm_parameter" "google_client_secret" {
  name = "${local.ssm_project_base_path}/google_client_secret"
}


# ### AWS Secrets manager ###
# # These secrets are either rotated or have tied lifecycle with AWS services, f.e RDS password
# data "aws_secretsmanager_secret" "another_secret" {
#   name = "${var.environment}/postgres_pass"
# }