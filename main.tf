### NOTESJ about reusable module logic ###
# Second part of try is the default value if the key is not found in config
# f.e try(var.ecs_app_config[each.key].container_desired_count, 1) -> means by default it will be 1 desired count

########################################################
######                ECS APPS                     #####
########################################################
module "ecs-apps" {
  for_each = var.enable_ecs_apps ? { for ecs_app, conf in var.ecs_app_config : ecs_app => conf } : {}
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
  vpc_subnets           = module.vpc.private_subnet_ids

  ## Public expose via ALB (if is_public_service is false, below options are irrelevant)
  is_public_service = true
  aws_route53_zone = data.aws_route53_zone.primary
  alb_listener_arn = aws_lb_listener.front_end_443.arn
  alb_rule_priority  = try(var.ecs_app_config[each.key].alb_rule_priority, 100)
  public_alb_dnsname = aws_lb.public-lb.dns_name

  # IAM
  execution_role_arn = module.ecs_task_execution_role.arn 
  task_role_arn      = module.ecs_task_role.arn
}

########################################################
######                    AUTH                     #####
########################################################
# module "cognito-user-pools" {
#   depends_on = [ module.ecs-apps ]
#   source = "./modules/cognito-user-pool"
#   frontend_url = "https://${module.ecs-apps["ens-fe"].domain_name}"

#   create_google_provider = var.create_google_provider
#   google_client_id = var.create_google_provider ? data.aws_ssm_parameter.google_client_id.value : ""
#   google_client_secret = var.create_google_provider ? data.aws_ssm_parameter.google_client_secret.value : ""
# }