data "aws_caller_identity" "accepter" {
  provider = aws.accepter
}

data "aws_region" "accepter" {
  provider = aws.accepter
}

data "aws_vpc" "accepter" {
  provider = aws.accepter

  filter {
    name   = "tag:Name"
    values = [var.accepter]
  }
}

data "aws_route_table" "accepter_private" {
  provider = aws.accepter
  vpc_id   = data.aws_vpc.accepter.id

  filter {
    name   = "tag:Route"
    values = ["private"]
  }
}

data "aws_route_table" "accepter_public" {
  provider = aws.accepter
  vpc_id   = data.aws_vpc.accepter.id

  filter {
    name   = "tag:Route"
    values = ["public"]
  }
}

resource "aws_route" "accepter_to_requester_private" {
  provider                  = aws.accepter
  route_table_id            = data.aws_route_table.accepter_private.id
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

resource "aws_route" "accepter_to_requester_public" {
  provider                  = aws.accepter
  route_table_id            = data.aws_route_table.accepter_public.id
  destination_cidr_block    = data.aws_vpc.requester.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}
