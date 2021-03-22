#Certificate creation and validation
resource "aws_acm_certificate" "root" {
  provider          = aws.us-east-1 # CF distributions require certificates in us-east-1
  domain_name       = var.dns_zone
  validation_method = "DNS"

  tags = {
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "root_certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.root.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  zone_id         = aws_route53_zone.eldritch-atlas.id
}

# Note this doesn't create an AWS 'resource' as such. it's a workflow-only item
resource "aws_acm_certificate_validation" "root_certificate_validation_workflow" {
  certificate_arn         = aws_acm_certificate.root.arn
  validation_record_fqdns = [for record in aws_route53_record.root_certificate_validation : record.fqdn]
  depends_on = [aws_route53_record.zone-delegation]  #  ensure the record will be reachable before attempting the dns-01 validation
}
