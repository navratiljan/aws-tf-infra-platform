### NOTESJ about reusable module logic ###
# Second part of try is the default value if the key is not found in config
# f.e try(var.ecs_app_config[each.key].container_desired_count, 1) -> means by default it will be 1 desired count

########################################################
######                ECS APPS                     #####
########################################################
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

########################################################
######   Optional Compute: EKS Karpenter cluster   #####
########################################################
module "eks" {
  count = var.enable_eks ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.infix}-kardem"
  cluster_version = "1.33"

  bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    aws-ebs-csi-driver = { 
      most_recent = true 
    }
  }
  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets


  iam_role_additional_policies = { "AmazonEBSCSIDriverPolicy" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" }
}


########################################################
######                    AUTH                     #####
########################################################
module "cognito-user-pools" {
  source = "./modules/cognito-user-pool"
  frontend_url = "https://ens-fe.navaws.ceacpoc.cloud"

  create_google_provider = var.create_google_provider
  google_client_id = var.create_google_provider ? data.aws_ssm_parameter.google_client_id.value : ""
  google_client_secret = var.create_google_provider ? data.aws_ssm_parameter.google_client_secret.value : ""
}