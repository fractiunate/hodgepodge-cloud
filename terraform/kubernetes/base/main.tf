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

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.stage}-aks-gitops-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "${var.stage}aksgitops${random_string.suffix.result}"
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "${var.resource_group_name}-nodes"
  sku_tier            = var.sla_sku

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
