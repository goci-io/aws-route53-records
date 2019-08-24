# aws-route53-records

**Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)**

This module provisions new records in an existing Route53 Hosted zone.

## Configuration

| Name | Description | Default |
|-------------------------|-----------------------------------------------------------|---------|
| hosted_zone | Name of the existing hosted zone | - |
| is_private_zone | Whether the hosted zone is private or public | false |
| records | Object of ttl, name, values and type to describe a record | - |
| tf_provider_aws_version | Version of the Terraform AWS provider | ~> 2.24 |

You can find an example [here](terraform.tfvars.example)