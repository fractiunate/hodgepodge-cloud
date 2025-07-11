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

resource "azurerm_container_app_environment" "this" {
  name                = "${var.stage}-environment-${var.container_app_name}-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  # infrastructure_subnet_id           = var.container_app_subnet_id
  # internal_load_balancer_enabled = true

  # log_analytics_workspace_id = var.log_analytics_workspace_id

  # Comment out workload profile to default to serverless/consumption
  # infrastructure_resource_group_name = "${var.resource_group_name}-infra"
  # workload_profile {
  #   name                  = "DedicatedE4"
  #   maximum_count         = 1
  #   minimum_count         = 1
  #   workload_profile_type = "E4"
  # }

  tags = local.tags
}


resource "azurerm_container_app" "app" {
  name                         = "${var.stage}-${var.container_app_name}-${random_string.suffix.result}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = azurerm_resource_group.this.name
  revision_mode                = "Single"

  # workload_profile_name = "DedicatedE4"


  template {
    container {
      name   = var.container_app_name
      image  = var.container_app_image
      cpu    = var.cpu
      memory = var.memory

      command = var.container_app_command
      args    = var.container_app_args

      dynamic "env" {
        for_each = var.container_app_env
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "readiness_probe" {
        for_each = var.readiness_probe != null ? [var.readiness_probe] : []
        content {
          transport               = readiness_probe.value.transport
          path                    = readiness_probe.value.path
          failure_count_threshold = readiness_probe.value.failure_count_threshold
          port                    = readiness_probe.value.port
        }
      }


      dynamic "liveness_probe" {
        for_each = var.liveness_probe != null ? [var.liveness_probe] : []
        content {
          transport               = liveness_probe.value.transport
          path                    = liveness_probe.value.path
          failure_count_threshold = liveness_probe.value.failure_count_threshold
          initial_delay           = liveness_probe.value.initial_delay
          port                    = liveness_probe.value.port
        }
      }


      dynamic "startup_probe" {
        for_each = var.startup_probe != null ? [var.startup_probe] : []
        content {
          transport               = startup_probe.value.transport
          path                    = startup_probe.value.path
          failure_count_threshold = startup_probe.value.failure_count_threshold
          port                    = startup_probe.value.port
        }
      }

    }
  }

  dynamic "secret" {
    for_each = var.container_app_secrets != null ? var.container_app_secrets : {}
    content {
      name                = secret.key
      identity            = secret.value.identity
      key_vault_secret_id = secret.value.key_vault_secret_id
    }
  }

  identity {
    type         = "SystemAssigned"
  }

  dynamic "ingress" {
    for_each = var.container_app_ingress != null ? [var.container_app_ingress] : []
    content {
      external_enabled = ingress.value.external_enabled
      target_port      = ingress.value.target_port
      traffic_weight {
        percentage      = ingress.value.traffic_weight.percentage
        latest_revision = ingress.value.traffic_weight.latest_revision
      }
    }
  }
}

