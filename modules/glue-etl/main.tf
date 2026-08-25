resource "aws_glue_catalog_database" "db" {
    name = "${var.etl-name}-catalog-db"
}
resource "aws_glue_crawler" "example" {
  database_name = aws_glue_catalog_database.db.name
  name = "${var.etl-name}-crawler"
  role          =  var.iam_role_arn_crawler

  s3_target {
    #path = "s3://${module.s3_bucket["olympic-games-2024-datasets-bronze"].s3_bucket_id}"
    path = var.s3_path_crawler

  }

  #schedule = "cron(0 * * * ? *)"
  schedule = var.crawler_schedule

}

# resource "aws_s3_object" "test_deploy_script_s3" {
#   #bucket = module.s3_bucket["etl-job-scripts"].s3_bucket_id
#   bucket = var.s3_scripts_bucket_name
#   key = "${var.glue_dst_path}/testjob.py"
#   source = "${var.glue_src_path}/testjob.py"
#   etag = filemd5("${var.glue_src_path}/testjob.py")
# }

resource "aws_glue_job" "test_deploy_script" {
  glue_version = "4.0" 
  max_retries = 0 
  name = "${var.etl-name}-etl-job" 
  description = "test the deployment of an aws glue job to aws glue service with terraform" #description
  role_arn = var.iam_role_arn_etl
  number_of_workers = 2 
  worker_type = "G.1X" 
  timeout = "60" 
  execution_class = "FLEX" 
  tags = merge(var.tags, {
    Name = "${var.etl-name}-etl-job"
  })
  command {
    name="glueetl" 
    script_location = "s3://${var.s3_scripts_bucket_name}/${var.glue_dst_path}/testjob.py" 
  }
  default_arguments = {
    "--class"                   = "GlueApp"
    "--enable-job-insights"     = "true"
    "--enable-auto-scaling"     = "false"
    "--enable-glue-datacatalog" = "true"
    "--job-language"            = "python"
    "--job-bookmark-option"     = "job-bookmark-disable"
    "--datalake-formats"        = "iceberg"
    "--conf"                    = "spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions  --conf spark.sql.catalog.glue_catalog=org.apache.iceberg.spark.SparkCatalog  --conf spark.sql.catalog.glue_catalog.warehouse=s3://tnt-erp-sql/ --conf spark.sql.catalog.glue_catalog.catalog-impl=org.apache.iceberg.aws.glue.GlueCatalog  --conf spark.sql.catalog.glue_catalog.io-impl=org.apache.iceberg.aws.s3.S3FileIO"
  }
}

