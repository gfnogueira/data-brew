resource "aws_vpn_gateway" "this" {
  count  = var.enable_vpn_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-vpn-private-gateway", var.organization_account_name)
  }
}