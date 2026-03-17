provider "http" {}

data "http" "my_ip" {
  url = "http://checkip.amazonaws.com"
}

locals {
  my_ip = ["${trimspace(data.http.my_ip.response_body)}/32"]
}

output "my_ip" {
  value = local.my_ip
}