locals {
  vpc = {
    cidr_block = "10.201.0.0/16"
  }
}

module "vpc" {
  source                    = "./modules/aws/vpc"
  organization_account_name = local.organization_account_name
  cidr_block                = local.vpc.cidr_block
}