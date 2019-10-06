terraform {
  required_version = ">= 0.12.1"

  required_providers {
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

locals {
  records       = [for record in var.records : if lookup(record, "alias", "") == ""]
  alias_records = [for record in var.records : if lookup(record, "alias", "") != ""]
}

resource "aws_route53_record" "record" {
  count           = length(local.records)
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = format("%s.%s", lookup(local.records[count.index], "name"), var.hosted_zone)
  type            = lookup(local.records[count.index], "type", "A")
  ttl             = lookup(local.records[count.index], "ttl", 600)
  records         = lookup(local.records[count.index], "values", [])
  allow_overwrite = lookup(local.records[count.index], "overwrite", true)
}

resource "aws_route53_record" "alias_record" {
  count           = length(local.alias_records)
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = format("%s.%s", lookup(local.alias_records[count.index], "name"), var.hosted_zone)
  type            = lookup(local.alias_records[count.index], "type", "A")
  allow_overwrite = lookup(local.alias_records[count.index], "overwrite", true)

  alias {
    name                   = lookup(local.alias_records[count.index], "alias", join("", data.terraform_remote_state.alias.*.outputs.dns_name))
    zone_id                = lookup(local.alias_records[count.index], "alias_zone", join("", data.terraform_remote_state.alias.*.outputs.zone_id))
    evaluate_target_health = true
  }
}

