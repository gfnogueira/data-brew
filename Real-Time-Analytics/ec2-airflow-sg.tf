resource "aws_security_group" "sg_infra_airflow" {
  name        = "sg_infra_airflow"
  description = "Allow access to intranet instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = local.my_ip
    description = "Nogueira infrastructure IP range"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "airflow"
    env   = local.account_name
    layer = "infrastructure"
  }
}
