resource "aws_vpc_peering_connection" "peer" {
  provider = aws.requester

  vpc_id = data.aws_vpc.requester.id

  peer_vpc_id   = data.aws_vpc.accepter.id
  peer_owner_id = data.aws_caller_identity.accepter.account_id
  peer_region   = data.aws_region.accepter.name

  auto_accept = false

  tags = {
    Side = "requester"
    Name = format("%s-to-%s", var.requester, var.accepter)
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "accepter"
    Name = format("%s-to-%s", var.requester, var.accepter)
  }
}

resource "aws_vpc_peering_connection_options" "requester" {
  provider                  = aws.requester
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  requester {
    allow_remote_vpc_dns_resolution  = true
    #allow_classic_link_to_remote_vpc = false
    #allow_vpc_to_remote_classic_link = false
  }

  depends_on = [
    aws_vpc_peering_connection_accepter.peer,
  ]
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id

  accepter {
    allow_remote_vpc_dns_resolution  = true
    #allow_classic_link_to_remote_vpc = false
    #allow_vpc_to_remote_classic_link = false
  }

  depends_on = [
    aws_vpc_peering_connection_accepter.peer
  ]
}