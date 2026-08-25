data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
locals {
  tags = {
    env      = var.environment
    project  = var.project_name
    location = var.region
  }

  infix = "${var.project_name}-${var.environment}"
  prefix = "${var.project_name}-${var.environment}"
}
locals {
  account_id      = data.aws_caller_identity.current.account_id
  cluster_version = "1.27"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  glue_src_path = "../olympics-data-platform-etl/etl-spark-jobs"
  ssm_project_base_path = "/${var.project_name}/${var.environment}"
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

