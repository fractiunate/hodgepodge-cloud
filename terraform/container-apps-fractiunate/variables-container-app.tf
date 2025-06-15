variable "container_app_name" {
  type     = string
  nullable = false
}

variable "cpu" {
  type    = number
  default = 0.25
}

variable "memory" {
  type    = string
  default = "0.5Gi"
}

variable "container_app_image" {
  type     = string
  nullable = false
}

variable "container_app_env" {
  type    = map(string)
  default = {}
}

variable "container_app_args" {
  type    = list(string)
  default = []
}

variable "container_app_command" {
  type    = list(string)
  default = []
}

variable "readiness_probe" {
  type = object({
    transport               = string
    path                    = string
    failure_count_threshold = number
    port                    = number
  })
  default = null
}

variable "liveness_probe" {
  type = object({
    transport               = string
    path                    = string
    failure_count_threshold = number
    initial_delay           = number
    port                    = number
  })
  default = null
}

variable "startup_probe" {
  type = object({
    transport               = string
    path                    = string
    failure_count_threshold = number
    port                    = number
  })
  default = null
}

variable "container_app_secrets" {
  type = map(object({
    identity            = string
    key_vault_secret_id = string
  }))
  default = {}
}

variable "container_app_ingress" {
  type = object({
    target_port      = number
    external_enabled = optional(bool, false)
    traffic_weight = object({
      percentage      = number
      latest_revision = bool
    })
  })
  default = null
}
