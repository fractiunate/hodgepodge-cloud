resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_service_plan" "this" {
  name                = "asp-${var.stage}-docker-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = local.tags
}

resource "azurerm_linux_web_app" "this" {
  name                    = "ase-${var.stage}-docker-${random_string.suffix.result}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  service_plan_id         = azurerm_service_plan.this.id
  https_only              = true
  tags                    = local.tags
  client_affinity_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version    = "1.2"
    health_check_path      = var.health_check_path
    vnet_route_all_enabled = var.subnet_id_app_services != null

    application_stack {
      docker_image_name        = "${var.docker.image}:${var.docker.tag}"
      docker_registry_url      = "https://${var.docker.registry_url}"
      docker_registry_username = var.docker.registry_username != "" ? var.docker.registry_username : null
      docker_registry_password = var.docker.registry_password != "" ? var.docker.registry_password : null
    }

    dynamic "ip_restriction" {
      for_each = { for subnet in ["subnet"] : subnet => subnet if var.subnet_id_app_services != null }
      content {
        action                    = "Allow"
        virtual_network_subnet_id = var.subnet_id_app_services
        priority                  = 9
      }
    }

    dynamic "ip_restriction" {
      for_each = length(var.whitelist_ips) > 0 ? toset(var.whitelist_ips) : []
      content {
        action     = "Allow"
        ip_address = ip_restriction.value
        priority   = 10 + index(var.whitelist_ips, ip_restriction.value)
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = length(var.whitelist_ips) > 0 ? toset(var.whitelist_ips_scm) : []
      content {
        action     = "Allow"
        ip_address = scm_ip_restriction.value
        priority   = 10 + index(var.whitelist_ips_scm, scm_ip_restriction.value)

      }
    }

    # default deny all when whitelist is provided
    dynamic "ip_restriction" {
      for_each = length(var.whitelist_ips) > 0 ? ["default_deny_all"] : []
      content {
        action     = "Deny"
        ip_address = "0.0.0.0/0"
        priority   = 64000
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = length(var.whitelist_ips) > 0 ? ["default_deny_all_scm"] : []
      content {
        action     = "Deny"
        ip_address = "0.0.0.0/0"
        priority   = 64000
      }
    }

    always_on = true
  }

  app_settings = merge(var.app_environments, {
    WEBSITE_DNS_SERVER                  = "168.63.129.16"
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "TRUE"
  })

  logs {
    application_logs {
      file_system_level = var.app_log_level
    }
    dynamic "http_logs" {
      for_each = var.http_logs != null ? ["enabled"] : []
      content {
        file_system {
          retention_in_days = var.http_logs.log_retention_in_days
          retention_in_mb   = var.http_logs.log_retention_in_mb
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      virtual_network_subnet_id, # see: https://github.com/hashicorp/terraform-provider-azurerm/issues/18288#issuecomment-1272840733
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  count          = var.subnet_id_app_services != null ? 1 : 0
  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.subnet_id_app_services
}
