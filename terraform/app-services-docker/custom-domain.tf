resource "azurerm_dns_txt_record" "validation" {
  count               = custom_domain != null
  name                = join(".", ["asuid", var.custom_domain.subdomain])
  zone_name           = var.custom_domain.domain_name
  resource_group_name = var.custom_domain.resource_group_name
  ttl                 = 300

  record {
    value = azurerm_linux_web_app.this.custom_domain_verification_id
  }

  tags = local.tags
}

resource "azurerm_app_service_certificate" "this" {
  count               = custom_domain != null
  name                = "${var.stage}-docker-cert-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  pfx_blob            = var.certificate_blob_b64 != "" ? var.certificate_blob_b64 : acme_certificate.certificate[0].certificate_p12
}

resource "azurerm_app_service_custom_hostname_binding" "website_app_hostname_bind" {
  count               = custom_domain != null
  hostname            = "${var.custom_domain.subdomain}.${var.custom_domain.domain_name}"
  app_service_name    = azurerm_linux_web_app.this.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_app_service_certificate_binding" "bind_certificate_to_webapp" {
  count               = custom_domain != null
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.website_app_hostname_bind[0].id
  ssl_state           = "SniEnabled"
  certificate_id      = azurerm_app_service_certificate.this[0].id
}
