locals {
  resource_ssm = format("%s/ssh_key", var.key_name)
}

resource "aws_ssm_parameter" "private_key_pem" {
  name  = format("/%s/private-key-pem", local.resource_ssm)
  type  = "SecureString"
  value = tls_private_key.this.private_key_pem
}

resource "aws_ssm_parameter" "public_key_pem" {
  name  = format("/%s/public-key-pem", local.resource_ssm)
  type  = "String"
  value = tls_private_key.this.public_key_pem
}

resource "aws_ssm_parameter" "public_key_openssh" {
  name  = format("/%s/public-key-openssh", local.resource_ssm)
  type  = "String"
  value = tls_private_key.this.public_key_openssh
}
