
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
    ttl       = number
    name      = string
    values    = list(string)
    type      = string
    overwrite = bool
  }))
  description = "Records to add to the hosted zone"
}
