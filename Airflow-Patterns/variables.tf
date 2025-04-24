locals {

  cidrs = {
    nogs-pocs = [local.vpc.cidr_block]
  }
}
