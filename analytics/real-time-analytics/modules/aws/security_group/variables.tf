variable "egress_from_port" {
  type = number
  default = 0
}
variable "egress_to_port" {
  type = number
  default = 0
}
variable "cidr_blocks_egress" {
  type = string
  default = "0.0.0.0/0"
}
variable "name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "ingress_from_port" {
  type = number
}
variable "ingress_to_port" {
  type = number
}
variable "cidr_blocks_ingress" {
  type = string
  default = "0.0.0.0/0"
}
