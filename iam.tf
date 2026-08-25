# +----------------------------------------------------------+
# |                     ECS APPS                             |
# +----------------------------------------------------------+
module "ecs_task_execution_role" {
  source = "./modules/iam"
  iam_role_name = "ecs-task-execution-role"
  policy_attachments = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    ]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

module "ecs_task_role" {
  source = "./modules/iam"
  iam_role_name = "ecs-task-role"
  policy_attachments = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    ]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com", "quicksight.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  custom_policies = {
   ecs-task-custom-policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
      },
       {
       "Effect": "Allow",
       "Action": "quicksight:*",
      "Resource": "*"
      }
   ]
}
EOF
  ecs-fe-quicksight-policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "quicksight:RegisterUser",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "quicksight:GetDashboardEmbedUrl",
            "Resource": "arn:aws:quicksight:eu-central-1:812222239604:dashboard/70e99648-2579-4784-9f6f-d6056bdff9d8",
            "Effect": "Allow"
        },
        {
            "Action": "sts:AssumeRole",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
  }
}

# +----------------------------------------------------------+
# |                          GLUE                            |                             
# +----------------------------------------------------------+
module "glue_data_quality_role" {
  source = "./modules/iam"
  iam_role_name = "glue-data-quality-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "scheduler.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
} 
EOF
  custom_policies = {
    glue-data-quality-policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "glue:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "cloudwatch:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "s3:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "logs:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "sqs:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "events:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "scheduler:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "schemas:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "iam:PassRole",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}
}

module "glue_data_crawler_role" {
  source = "./modules/iam"
  iam_role_name = "glue-data-crawler-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  policy_attachments = [ 
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

#   custom_policies = {
#     "AWSGlueServiceRole-CrawlerOlympicData-s3Policy" = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:GetObject",
#                 "s3:PutObject"
#             ],
#             "Resource": [
#                 "${module.s3_bucket.bucket_arn}*"
#             ]
#         }
#     ]
# }
# EOF
}

module "glue_etl_jobs_role" {
  source = "./modules/iam"
  iam_role_name = "glue-etl-jobs-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
  policy_attachments = [ 
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

#   custom_policies = {
#     "AWSGlueServiceRole-CrawlerOlympicData-s3Policy" = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:GetObject",
#                 "s3:PutObject"
#             ],
#             "Resource": [
#                 "${module.s3_bucket.bucket_arn}*"
#             ]
#         }
#     ]
# }
# EOF
}