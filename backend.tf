terraform {
    backend "s3" {
        bucket         = "aws-tf-infra-platform-435472314818-s3-tfstate-prod-01"
        key            = "aws-tf-infra-platform-prod.tfstate"
        region         = "eu-central-1"
        dynamodb_table = "aws-tf-infra-platform-435472314818-s3-tflocks-prod-01"
    }
}
