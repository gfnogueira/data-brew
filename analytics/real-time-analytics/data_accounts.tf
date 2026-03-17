locals {
  accounts_ssm = ["nogueira_account"]
}

data "aws_ssm_parameter" "account_id" {
  for_each = toset(local.accounts_ssm)
  name     = format("/organizations/account-id/%s", each.value)
}