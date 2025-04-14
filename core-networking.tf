resource "aws_route53_zone" "primary" {
  name = "navaws.ceacpoc.cloud"
}
resource "aws_route53_record" "default_certificate" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "default"
  type    = "CNAME"
  ttl     = 10


  records = [aws_lb.public-lb.dns_name]
}
resource "aws_acm_certificate" "default" {
  domain_name       = "${aws_route53_record.default_certificate.name}.${aws_route53_zone.primary.name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.default.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.primary.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.default.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

resource "aws_lb" "public-lb" {
  name               = "${local.infix}-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.aws_lb_sg.security_group_id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "logselb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}
resource "aws_lb_listener" "front_end_80" {
  load_balancer_arn = aws_lb.public-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "front_end_443" {
  load_balancer_arn = aws_lb.public-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.default.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No valid URL's found, default response from ALB. Replace by error pages"
      status_code  = "400"
    }
  }
}


module "aws_lb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${local.infix}-ecs-sg"
  description = "Security group to be used with ECS LB"
  vpc_id      = module.vpc.vpc_id

  ## INGRESS ##
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP inbound traffic"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS inbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]


  ## EGRESS ##
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all traffic out"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}