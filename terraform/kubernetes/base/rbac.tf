resource "azurerm_role_assignment" "dns_sp_network_contributor" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Network Contributor"
  scope                            = "/subscriptions/${var.dns_zone_subscription_id}/resourceGroups/${var.dns_zone_resource_group_name}"
  skip_service_principal_aad_check = true
}
