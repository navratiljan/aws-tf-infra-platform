region="eu-central-1"
environment="prod"
project_name="exampleproject"
postgres_user= "postgresuserprod"
another_non_secret_variable="prod-somevalue"

## FLAGS
enable_compute = false
enable_eks = false

# Undestand CPU and memory sizing https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
ecs_app_config = {
  ens-api = {
    alb_rule_priority = 110
    container_cpu = 2
    container_memory = 512
    container_port = 80
    host_port = 80
    container_desired_count = 1
    environment_variables = [
        {
        name  = "S3_DATASETS_BUCKET_NAME"
        value = "environmental-app-dataset-bucket"
        },
        {
        name  = "DYNAMODB_TABLE"
        value = "table-environmental-dataset-fastapi"
      }
    ]
    ecr_image_tag = "v1.0.1"
    force_delete_ecr = false
    sg_inbound_cidr_block = ""
  }
  ens-fe = {
    alb_rule_priority = 100
    container_cpu = 1
    container_memory = 512
    container_port = 80
    host_port = 80
    container_desired_count = 1
    environment_variables = [
    ]
    ecr_image_tag = "v1.0.2"
    force_delete_ecr = false
    sg_inbound_cidr_block = ""
  }
}

s3_bucket_config = {
  olympic-games-2024-datasets-bronze = {
    bucket_name = "olympic-games-2024-datasets-bronze"
    versioning_enabled = false
  }
  olympic-games-2024-datasets-silver = {
    bucket_name = "olympic-games-2024-datasets-silver"
    versioning_enabled = false
  }
  etl-job-scripts = {
    bucket_name = "olympic-etl-job-scripts"
    versioning_enabled = true
  }
}
