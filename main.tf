### NOTESJ about reusable module logic ###
# Second part of try is the default value if the key is not found in config
# f.e try(var.ecs_app_config[each.key].container_desired_count, 1) -> means by default it will be 1 desired count

### ECS APPS ###
module "ecs-apps" {
  for_each = var.enable_compute ? { for ecs_app, conf in var.ecs_app_config : ecs_app => conf } : {}
  source   = "./modules/ecs"

  infix            = local.infix
  region           = var.region
  application_name = each.key

  # App container definition
  container_cpu         = try(var.ecs_app_config[each.key].container_cpu, 2)
  container_memory      = try(var.ecs_app_config[each.key].container_memory, 512)
  container_port        = try(var.ecs_app_config[each.key].container_port, 80)
  host_port             = try(var.ecs_app_config[each.key].host_port, 80)
  volumes               = try(var.ecs_app_config[each.key].volumes, {})
  environment_variables = try(var.ecs_app_config[each.key].environment_variables, [])
  ecr_image_tag = try(var.ecs_app_config[each.key].ecr_image_tag, "latest")
  force_delete_ecr = try(var.ecs_app_config[each.key].force_delete_ecr, false)
  

  # Deployment strategy behavior
  enable_circuit_breaker   = try(var.ecs_app_config[each.key].enable_circuit_breaker, false)
  rollback_circuit_breaker = try(var.ecs_app_config[each.key].rollback_circuit_breaker, false)
  placement_constraints    = try(var.ecs_app_config[each.key].placement_constraints, [])
  container_desired_count  = try(var.ecs_app_config[each.key].container_desired_count, 1)

  # Networking
  # sg_inbound_cidr_block = var.ecs_app_config[each.key].sg_inbound_cidr_block
  sg_inbound_cidr_block = local.vpc_cidr
  vpc_id                = module.vpc.vpc_id
  vpc_subnets           = module.vpc.private_subnets

  ## Public expose via ALB (if is_public_service is false, below options are irrelevant)
  is_public_service = true
  aws_route53_zone = aws_route53_zone.primary
  alb_listener_arn = aws_lb_listener.front_end_443.arn
  alb_rule_priority  = try(var.ecs_app_config[each.key].alb_rule_priority, 100)
  public_alb_dnsname = aws_lb.public-lb.dns_name

  # IAM
  execution_role_arn = module.ecs_task_execution_role.arn 
  task_role_arn      = module.ecs_task_role.arn
}

## VPC ##
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "${local.infix}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_ipv6            = false
  create_egress_only_igw = true


  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "s3_bucket" {
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
  policy = try(var.s3_bucket_config.policy, null)
  attach_policy = try(var.s3_bucket_config.attach_policy, false)

  tags = merge(local.tags, {
    Name = var.s3_bucket_config[each.key].bucket_name
  })
}

## AUTH ##
#TODO add googlecloud ouath object as well here if google is on
module "cognito-user-pools" {
  source = "./modules/cognito-user-pool"
  frontend_url = "https://ens-fe.navaws.ceacpoc.cloud"
}