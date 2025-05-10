locals {
  organization_name         = "nogs"
  account_name              = "pocs"
  account_region            = "us-east-1"
  organization_account_name = format("%s-%s", local.organization_name, local.account_name)
}
locals {
  dnsprivate = {
    dns_name = format("%s.com.br", local.organization_name)
  }
  dnspublic = {
    dns_name = format("%s.com.br", local.organization_name)
  }
}