locals {
  private_subnets = {
    name                    = format("%s-private-subnet", local.resource_name)
    route                   = "private"
    map_public_ip_on_launch = false
  }
  public_subnets = {
    name                    = format("%s-public-subnet", local.resource_name)
    route                   = "public"
    map_public_ip_on_launch = false
  }
}

resource "aws_subnet" "private" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = local.private_subnets.map_public_ip_on_launch

  tags = {
    Name  = format("%s-%s", local.private_subnets.name, replace(element(data.aws_availability_zones.available.names, count.index), data.aws_region.current.name, ""))
    Route = local.private_subnets.route
  }
}

resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 6)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = local.public_subnets.map_public_ip_on_launch

  tags = {
    Name  = format("%s-%s", local.public_subnets.name, replace(element(data.aws_availability_zones.available.names, count.index), data.aws_region.current.name, ""))
    Route = local.public_subnets.route
  }
}
