variable "name" {}
variable "environment" {}
variable "ami" {}
variable "policy" {}
variable "instance_type" {}
variable "iam_instance_profile" {}
variable "key_name" {
  type = string
}
variable "vpc_security_group_ids" {
  type = list(string)
}
variable "subnets" {
  type = list(any)
}
variable "volume_size" {}
variable "volume_type" {}
variable "snapshot" {
  default = false
}
variable "userdata" {}
variable "disable_api_termination" {}
variable "public_instance" {
  description = "A flag indicating whether a public IP should be associated with the instance"
  type        = bool
  default     = false
}

variable "public_instance_eip" {
  type        = bool
  default     = false
}
variable "network_secondary" {
  type        = bool
  default     = false
  description = "Add Secondary Interface Network in the EC2"
}
