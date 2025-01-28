data "aws_caller_identity" "requester" {
  provider = aws.requester
}

data "aws_region" "requester" {
  provider = aws.requester
}

data "aws_vpc" "requester" {
  provider = aws.requester

  filter {
    name   = "tag:Name"
    values = [var.requester]
  }
}

data "aws_route_table" "requester_private" {
  provider = aws.requester
  vpc_id   = data.aws_vpc.requester.id

  filter {
    name   = "tag:Route"
    values = ["private"]
  }
}

data "aws_route_table" "requester_public" {
  provider = aws.requester
  vpc_id   = data.aws_vpc.requester.id

  filter {
    name   = "tag:Route"
    values = ["public"]
  }
}

resource "aws_route" "requester_to_accepter_private" {
  provider                  = aws.requester
  route_table_id            = data.aws_route_table.requester_private.id
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

resource "aws_route" "requester_to_accepter_public" {
  provider                  = aws.requester
  route_table_id            = data.aws_route_table.requester_public.id
  destination_cidr_block    = data.aws_vpc.accepter.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}
