resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_eventhub_namespace" "tickets" {
  name                = "${var.stage}-ehn-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.eventhub_sku
  # capacity            = 1
  tags = local.tags
}

resource "azurerm_eventhub" "approved_tickets" {
  name              = "approved-tickets"
  namespace_id      = azurerm_eventhub_namespace.tickets.id
  partition_count   = 1
  message_retention = var.eventhub_message_retention
}
