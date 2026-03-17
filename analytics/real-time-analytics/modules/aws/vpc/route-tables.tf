locals {
  private_route_table = {
    name       = format("%s-private-route-table", local.resource_name)
    cidr_block = "0.0.0.0/0"
    route      = "private"
  }
  public_route_table = {
    name       = format("%s-public-route-table", local.resource_name)
    cidr_block = "0.0.0.0/0"
    route      = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = local.private_route_table.cidr_block
      nat_gateway_id = aws_nat_gateway.this[0].id
    }
  }

  tags = {
    Name  = local.private_route_table.name
    Route = local.private_route_table.route
  }

  lifecycle {
    ignore_changes = [
      route,
    ]
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = local.public_route_table.cidr_block
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name  = local.public_route_table.name
    Route = local.public_route_table.route
  }
  lifecycle {
    ignore_changes = [
      route,
    ]
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
