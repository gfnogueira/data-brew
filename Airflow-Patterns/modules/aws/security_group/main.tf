resource "aws_security_group" "this" {
  vpc_id      = var.vpc_id
  name        = "${var.name}-security-group"
  description = "${var.name}-ECS Security Group"
  egress {
    from_port   = var.egress_from_port
    protocol    = "-1"
    to_port     = var.egress_to_port
    cidr_blocks = [var.cidr_blocks_egress]
  }
  ingress {
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
    protocol    = "tcp"
    cidr_blocks = [var.cidr_blocks_ingress]
  }
}
