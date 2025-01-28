locals {
  vpc_name              = format("%s", local.resource_name)
  nat_gateway_name      = format("%s-nat-gateway", local.resource_name)
  internet_gateway_name = format("%s-internet-gateway", local.resource_name)
  elastic_ip            = format("%s-elastic-ip", local.resource_name)
}

resource "aws_vpc" "this" {
  cidr_block                       = var.cidr_block
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = local.vpc_name
  }
}

resource "aws_eip" "this" {
  count  = var.enable_nat_gateway ? 1 : 0
  depends_on = [aws_vpc.this]
}

resource "aws_nat_gateway" "this" {
  count  = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.this[count.index]
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = local.nat_gateway_name
  }

  depends_on = [aws_subnet.public]
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = local.internet_gateway_name
  }

  depends_on = [aws_vpc.this]
}
