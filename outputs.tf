output "fqdn" {
  value = join("", coalescelist(aws_route53_record.record.*.fqdn, aws_route53_record.alias_record.*.fqdn, [""]))
}
