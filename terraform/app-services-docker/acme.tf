resource "tls_private_key" "private_key" {
  count     = var.custom_domain != null && var.certificate_blob_b64 == null ? 1 : 0
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  count           = var.custom_domain != null && var.certificate_blob_b64 == null ? 1 : 0
  account_key_pem = tls_private_key.private_key[0].private_key_pem
  email_address   = "hostmaster@fractiunate.de"
}

resource "acme_certificate" "certificate" {
  count              = var.custom_domain != null && var.certificate_blob_b64 == null ? 1 : 0
  account_key_pem    = acme_registration.reg[0].account_key_pem
  common_name        = "${var.custom_domain.subdomain}.${var.custom_domain.domain_name}"
  min_days_remaining = 90
  dns_challenge {
    provider = "azuredns"

    config = {
      AZURE_SUBSCRIPTION_ID = var.ARM_SUBSCRIPTION_ID
      AZURE_RESOURCE_GROUP  = var.resource_group_name
    }
  }
}

# data "azurerm_client_config" "current" {}

