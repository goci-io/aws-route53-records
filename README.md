# aws-route53-records

**Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)**

This module provisions new records in an existing Route53 Hosted zone.

## Usage

```hcl
module "zone" {
  source      = "git::https://github.com/goci-io/aws-route53-records.git?ref=tags/<latest-version>"
  hosted_zone = "goci.io"
  records     = [
    {
      ttl       = 300
      name      = "confirmation-dns-record"
      values    = ["confirmation-value"]
      type      = "TXT"
      overwrite = true
    }
  ]
}
```

## Configuration

| Name | Description | Default |
|-------------------------|-----------------------------------------------------------|---------|
| hosted_zone | Name of the existing hosted zone | - |
| is_private_zone | Whether the hosted zone is private or public | false |
| records | Object of ttl, name, values, overwrite and type to describe a record | - |

You can find an example [here](terraform.tfvars.example)
