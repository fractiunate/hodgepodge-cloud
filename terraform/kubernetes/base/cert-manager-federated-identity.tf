
data "azurerm_resource_group" "dns" {
  provider = azurerm.dns
  count    = try(var.custom_domain.resource_group_name, null) != null ? 1 : 0
  name     = var.custom_domain.resource_group_name
}

resource "azurerm_user_assigned_identity" "aks_workload_identity" {
  count               = var.workload_identity_enabled ? 1 : 0
  location            = var.location
  name                = "${var.stage}aksgitops${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_federated_identity_credential" "cert_manager_federated_identity" {
  count               = var.workload_identity_enabled ? 1 : 0
  name                = "${var.stage}-cert-manager-federated-identity-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.aks_workload_identity[0].id
  subject             = "system:serviceaccount:certificates:cert-manager"
}

resource "azurerm_role_assignment" "dns" {
  count                = try(var.custom_domain.domain_name, null) != null && var.workload_identity_enabled ? 1 : 0
  scope                = try(var.custom_domain.resource_group_name, null) == null ? azurerm_resource_group.this.id : data.azurerm_resource_group.dns[0].id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_workload_identity[0].principal_id
  depends_on = [
    azurerm_user_assigned_identity.aks_workload_identity
  ]
}
