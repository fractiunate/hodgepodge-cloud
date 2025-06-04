resource "azurerm_storage_account" "fileshare" {
  count                         = var.deploy_storage ? 1 : 0
  name                          = "${var.stage}saacanginx${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.this.name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
  https_traffic_only_enabled    = true
}

resource "azurerm_storage_share" "nginx" {
  count              = var.deploy_storage ? 1 : 0
  name               = "nginx"
  storage_account_id = azurerm_storage_account.fileshare[0].id
  quota              = 5
}

resource "azurerm_container_app_environment_storage" "fileshare" {
  count                        = var.deploy_storage ? 1 : 0
  name                         = "${var.stage}acanginxfs${random_string.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  account_name                 = azurerm_storage_account.fileshare[0].name
  share_name                   = azurerm_storage_share.nginx[0].name
  access_key                   = azurerm_storage_account.fileshare[0].primary_access_key
  access_mode                  = "ReadOnly"
}

resource "azurerm_role_assignment" "aca_file_reader" {
  count                = var.deploy_storage ? 1 : 0
  scope                = azurerm_storage_account.fileshare[0].id
  role_definition_name = "Storage File Data SMB Share Reader" # Replace with Storage File Data SMB Share Contributor if ACA needs write access.
  principal_id         = azurerm_user_assigned_identity.containerapp[0].principal_id
}

