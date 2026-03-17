locals {
  resource_type = "vpc"
  resource_name = var.identifier != null ? format("%s-%s-%s", var.organization_account_name, var.identifier, local.resource_type) : format("%s-%s", var.organization_account_name, local.resource_type)
}

variable "identifier" {
  default = null
}
variable "organization_account_name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "enable_vpn_gateway" {
  default = false
}

variable "enable_nat_gateway" {
  default = false
}