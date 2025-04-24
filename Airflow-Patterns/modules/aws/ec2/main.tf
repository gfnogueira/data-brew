resource "aws_instance" "this" {
  ami                         = var.ami
  associate_public_ip_address = var.public_instance
  disable_api_termination     = var.disable_api_termination
  instance_type               = var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnets[0]
  user_data                   = file(var.userdata)

  root_block_device {
    delete_on_termination = false
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    tags = {
      Name     = var.name
      Snapshot = var.snapshot
    }
  }

  tags = {
    Name     = var.name
    env      = var.environment
    Snapshot = var.snapshot
  }
}

resource "aws_eip" "this" {
  count    = var.public_instance_eip ? 1 : 0
  instance = aws_instance.this.id

  tags = {
    Name = var.name
    env  = var.environment
  }
}