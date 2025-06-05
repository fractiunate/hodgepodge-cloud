resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_communication_service" "this" {
  name                = "${var.stage}-acs-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
  tags                = local.tags
}

# Create the Email Communication Service
resource "azurerm_email_communication_service" "this" {
  name                = "${var.stage}-acs-em-${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
  tags                = local.tags
}

resource "azurerm_email_communication_service_domain" "this" {
  name             = var.custom_domain != null ? var.custom_domain.domain_name : "AzureManagedDomain"
  email_service_id = azurerm_email_communication_service.this.id

  domain_management = var.custom_domain != null ? "CustomerManaged" : "AzureManaged"
  tags              = local.tags
}
