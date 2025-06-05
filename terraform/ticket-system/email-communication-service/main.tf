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
