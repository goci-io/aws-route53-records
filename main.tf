terraform {
  required_version = ">= 0.12.1"

  required_providers {
    aws = "~> 2.25"
  }
}

data "aws_route53_zone" "zone" {
  count        = var.enabled ? 1 : 0
  name         = var.hosted_zone
  private_zone = var.is_private_zone
}

data "terraform_remote_state" "alias" {
  count   = var.alias_module_state == "" ? 0 : var.enabled ? 1 : 0
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = var.alias_module_state
  }
}

locals {
  zone_id = join("", data.aws_route53_zone.zone.*.zone_id)
}

data "null_data_source" "record_fqdns" {
  count = var.enabled ? length(var.records) : 0

  inputs = {
    name = lookup(var.records[count.index], "name", "")
    full = length(regexall("${var.hosted_zone}.?$", lookup(var.records[count.index], "name", ""))) > 0
    fqdn = lookup(var.records[count.index], "name", "") == "" ? var.hosted_zone : format("%s.%s", lookup(var.records[count.index], "name"), var.hosted_zone)
  }
}

resource "aws_route53_record" "record" {
  count           = var.enabled ? length(var.records) : 0
  zone_id         = local.zone_id
  name            = data.null_data_source.record_fqdns[count.index].outputs.full ? data.null_data_source.record_fqdns[count.index].outputs.name : data.null_data_source.record_fqdns[count.index].outputs.fqdn
  type            = lookup(var.records[count.index], "type", "A")
  ttl             = lookup(var.records[count.index], "ttl", 600)
  records         = lookup(var.records[count.index], "values", [])
  allow_overwrite = lookup(var.records[count.index], "overwrite", true)
}

data "null_data_source" "alias_fqdns" {
  count = var.enabled ? length(var.alias_records) : 0

  inputs = {
    name = lookup(var.alias_records[count.index], "name", "")
    full = length(regexall("${var.hosted_zone}.?$", lookup(var.alias_records[count.index], "name", ""))) > 0
    fqdn = lookup(var.alias_records[count.index], "name", "") == "" ? var.hosted_zone : format("%s.%s", lookup(var.alias_records[count.index], "name"), var.hosted_zone)
  }
}

resource "aws_route53_record" "alias_record" {
  count           = var.enabled ? length(var.alias_records) : 0
  zone_id         = local.zone_id
  name            = data.null_data_source.alias_fqdns[count.index].outputs.full ? data.null_data_source.alias_fqdns[count.index].outputs.name : data.null_data_source.alias_fqdns[count.index].outputs.fqdn
  type            = lookup(var.alias_records[count.index], "type", "A")
  allow_overwrite = lookup(var.alias_records[count.index], "overwrite", true)

  alias {
    name                   = lookup(var.alias_records[count.index], "alias", join("", data.terraform_remote_state.alias.*.outputs.dns_name))
    zone_id                = lookup(var.alias_records[count.index], "alias_zone", join("", data.terraform_remote_state.alias.*.outputs.zone_id))
    evaluate_target_health = true
  }
}

