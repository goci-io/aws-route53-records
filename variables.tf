
variable "hosted_zone" {
  type        = string
  description = "Name of the hosted zone to create the records in"
}

variable "is_private_zone" {
  type        = bool
  default     = false
  description = "Whether the hosted zone is private or public"
}

variable "records" {
  type = list(object({
    ttl    = number
    name   = string
    values = list(string)
    type   = string
  }))
  description = "Records to add to the hosted zone"
}

variable "tf_provider_aws_version" {
  type        = string
  default     = "~> 2.24"
  description = "The version of the Terraform AWS provider"
}
