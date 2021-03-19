variable "region" {
  description = "Primary AWS Region"
  type        = string
}

variable "environment" {
  description = "Operational Environment"
  type        = string
}

variable "dns_zone" {
  description = "Primary DNS Zone"
  type        = string
}

variable "parent_dns_zone" {
  description = "Parent (top level) DNS Zone for use with delegations"
  type        = string
}
