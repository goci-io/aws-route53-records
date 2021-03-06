
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
  type        = list
  default     = []
  description = "Objects of records to add to the hosted zone"
}

variable "alias_records" {
  type        = list
  default     = []
  description = "Objects of alias records to add to the hosted zone"
}

variable "alias_module_state" {
  type        = string
  default     = ""
  description = "State reference to a module to source alias information from (only one). Must expose zone_id and dns_name outputs."
}

variable "tf_bucket" {
  type        = string
  default     = ""
  description = "The S3 Bucket to use to fetch state information from"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Disables the module if necessary (no count on modules)"
}

