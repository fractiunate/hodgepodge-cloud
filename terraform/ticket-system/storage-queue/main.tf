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


resource "azurerm_storage_account" "this" {
  name                     = "${var.stage}satickets${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "approved" {
  name                 = "approved"
  storage_account_name = azurerm_storage_account.this.name
}
