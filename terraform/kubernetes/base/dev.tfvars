resource_group_name          = "dev-fractiunate-aks-rg"
location                     = "West Europe"
dns_zone_subscription_id     = "f4ecd666-a977-4473-9512-5f77b64ea5c5"
dns_zone_resource_group_name = "rg-fractiunate-dns"
custom_domain = {
  domain_name         = "dev.fractiunate.com"
  resource_group_name = "rg-fractiunate-dns"
  dns_subscription_id = "f4ecd666-a977-4473-9512-5f77b64ea5c5"
}
