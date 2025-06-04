resource "azurerm_storage_account" "fileshare" {
  name                     = "${var.stage}sacanginx${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "react_content" {
  name               = "reactcontent"
  storage_account_id = azurerm_storage_account.fileshare.id
  quota              = 5
}
