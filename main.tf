terraform {
  required_version = ">= 0.12.1"

  required_providers = {
    aws = "~> 2.25"
  }
}

data "aws_route53_zone" "zone" {
  name         = var.hosted_zone
  private_zone = var.is_private_zone
}

data "terraform_remote_state" "alias" {
  count   = var.alias_module_state == "" ? 0 : 1
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = var.alias_module_state
  }
}

resource "aws_route53_record" "record" {
  count           = length(var.records)
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = format("%s.%s", lookup(var.records[count.index], "name"), var.hosted_zone)
  type            = lookup(var.records[count.index], "type", "A")
  ttl             = lookup(var.records[count.index], "ttl", 600)
  records         = lookup(var.records[count.index], "values", [])
  allow_overwrite = lookup(var.records[count.index], "overwrite", true)

  dynamic "alias" {
    iterator = alias
    for_each = var.alias_module_state == "" && lookup(var.records[count.index], "alias", "") == "" ? [] : [1]

    content {
      name                   = lookup(var.records[count.index], "alias", join("", data.terraform_remote_state.alias.*.outputs.dns_name))
      zone_id                = lookup(var.records[count.index], "alias_zone", join("", data.terraform_remote_state.alias.*.outputs.zone_id))
      evaluate_target_health = true
    }
  }
}
