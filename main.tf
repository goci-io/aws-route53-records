terraform {
  required_version = ">= 0.12.1"
  backend "s3" {}
}

data "aws_route53_zone" "zone" {
  name         = var.hosted_zone
  private_zone = var.is_private_zone
}

resource "aws_route53_record" "record" {
  count   = length(var.records)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = format("%s.%s", lookup(var.records[count.index], "name"), var.hosted_zone)
  type    = lookup(var.records[count.index], "type")
  ttl     = lookup(var.records[count.index], "ttl")
  records = lookup(var.records[count.index], "values")
}
