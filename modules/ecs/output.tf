output "domain_name" {
  value = aws_route53_record.alb_cname.fqdn
}