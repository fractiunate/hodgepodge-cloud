resource "azurerm_storage_account" "fileshare" {
  name                     = "${var.stage}sacanginx${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "nginx" {
  name               = "nginx"
  storage_account_id = azurerm_storage_account.fileshare.id
  quota              = 5
}

resource "azurerm_container_app_environment_storage" "fileshare" {
  name                         = "${var.stage}acanginxfs${random_string.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  account_name                 = azurerm_storage_account.fileshare.name
  share_name                   = azurerm_storage_share.nginx.name
  access_key                   = azurerm_storage_account.fileshare.primary_access_key
  access_mode                  = "ReadOnly"
}
