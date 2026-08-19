# Commented out example ##
module "s3_bucket" {
  #TODO S3 and ECR should be moved to different states
  source   = "terraform-aws-modules/s3-bucket/aws"
  version  = "4.1.1"
  for_each = { for s3_bucket, conf in var.s3_bucket_config : s3_bucket => conf }
  bucket                   = var.s3_bucket_config[each.key].bucket_name
  force_destroy            = try(var.s3_bucket_config.force_destroy, false)
  object_ownership         = try(var.s3_bucket_config.object_ownership, "BucketOwnerEnforced")
  versioning = {
    enabled = var.s3_bucket_config[each.key].versioning_enabled
  }

  # Predefined bucket policies
  attach_require_latest_tls_policy= try(var.s3_bucket_config.attach_require_latest_tls_policy, false)
  attach_deny_insecure_transport_policy= try(var.s3_bucket_config.attach_deny_insecure_transport_policy, false)
  attach_deny_unencrypted_object_uploads= try(var.s3_bucket_config.attach_deny_unencrypted_object_uploads, false)

  # Set this in case of custom bucket policies
  tags = merge(local.tags, {
    Name = var.s3_bucket_config[each.key].bucket_name
  })
}
resource "aws_s3_bucket" "alb_logs" {
  bucket = "my-elb-tf-test-bucket"

  force_destroy = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.bucket

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::054676820928:root"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}
