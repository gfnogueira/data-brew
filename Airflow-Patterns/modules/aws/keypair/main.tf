resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  count = var.create_key_pair ? 1 : 0

  key_name        = "KP-${var.key_name}"
  key_name_prefix = var.key_name_prefix
  public_key      = tls_private_key.this.public_key_openssh

  tags = var.tags
}

#resource "local_sensitive_file" "this" {
#  content = tls_private_key.this.private_key_pem
#
#  #filename            = pathexpand("~/.ssh/${var.key_name}.pem")
#  filename             = "ssh_keys/KP-${var.key_name}.pem"
#  file_permission      = "600"
#  directory_permission = "700"
#}