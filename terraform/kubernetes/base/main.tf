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

data "azurerm_resource_group" "dns" {
  count = try(var.custom_domain.resource_group_name, null) != null ? 1 : 0
  name  = var.custom_domain.resource_group_name
}

resource "azurerm_user_assigned_identity" "aks_workload_identity" {
  count               = var.workload_identity_enabled ? 1 : 0
  location            = var.location
  name                = "${var.stage}aksgitops${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}


resource "azurerm_role_assignment" "dns" {
  count                = var.workload_identity_enabled ? 1 : 0
  scope                = try(var.custom_domain.resource_group_name, null) == null ? azurerm_resource_group.this.id : data.azurerm_resource_group.dns[0].id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_workload_identity[0].principal_id
  depends_on = [
    azurerm_user_assigned_identity.aks_workload_identity
  ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                      = "${var.stage}-aks-gitops-${random_string.suffix.result}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.this.name
  dns_prefix                = "${var.stage}aksgitops${random_string.suffix.result}"
  kubernetes_version        = var.kubernetes_version
  node_resource_group       = "${var.resource_group_name}-nodes"
  sku_tier                  = var.sla_sku
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  lifecycle {
    ignore_changes = [
      tags["CreatedOnDate"]
    ]
  }

  identity {
    type = "SystemAssigned"
  }


  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = var.default_node_pool.vm_size
  }

  tags = local.tags
}
