module "bronze-etl" {
    source = "./modules/glue-etl"
    etl-name = "olympics-2024-bronze"
    s3_path_crawler = "s3://${module.s3_bucket["olympic-games-2024-datasets-bronze"].s3_bucket_id}"
    s3_scripts_bucket_name = module.s3_bucket["etl-job-scripts"].s3_bucket_id
    glue_src_path = "../olympics-data-platform-etl/etl-spark-jobs"
    glue_dst_path = "glue/scripts"
    tags = local.tags
    crawler_schedule = "cron(0 * * * ? *)"
    iam_role_arn_etl = module.glue_etl_jobs_role.arn
    iam_role_arn_crawler = module.glue_data_crawler_role.arn
    data_tier = "bronze"
}
module "silver-etl" {
    source = "./modules/glue-etl"
    etl-name = "olympics-2024-silver"
    s3_path_crawler = "s3://${module.s3_bucket["olympic-games-2024-datasets-silver"].s3_bucket_id}"
    s3_scripts_bucket_name = module.s3_bucket["etl-job-scripts"].s3_bucket_id
    glue_src_path = "../olympics-data-platform-etl/etl-spark-jobs"
    glue_dst_path = "glue/scripts"
    tags = local.tags
    crawler_schedule = ""
    iam_role_arn_etl = module.glue_etl_jobs_role.arn
    iam_role_arn_crawler = module.glue_data_crawler_role.arn
    data_tier = "silver"
}