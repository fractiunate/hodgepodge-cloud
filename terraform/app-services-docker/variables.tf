variable "resource_group_name" {
  description = "The name of the resource group for the static web hosting."
}

variable "location" {
  description = "The Azure region where the static web hosting will be deployed."
  default     = "West Europe"
}

variable "stage" {
  description = "The stage of the deployment (e.g., dev, int, prd)."
  default     = "dev"
}

variable "project" {
  description = "The name of the project for tagging purposes."
  default     = "app-services-docker"
}

variable "custom_domain" {
  nullable = true
  default  = null
  type = object({
    subdomain           = optional(string, "www")
    domain_name         = string
    dns_subscription_id = optional(string, null)
    resource_group_name = optional(string, null)
  })
  description = "The custom domain for the app service."
}

variable "subnet_id_app_services" {
  nullable    = true
  default     = null
  description = "Subnet ID for app service integration. If null, no VNet integration is applied."
}

variable "app_log_level" {
  description = "The log level for application logs."
  type        = string
  default     = "Off"
  validation {
    condition     = contains(["Error", "Warning", "Information", "Verbose", "Off"], var.app_log_level)
    error_message = "The app_log_level must be one of: Error, Warning, Information, Verbose, Off."
  }
}

variable "http_logs" {
  nullable    = true
  default     = null
  description = "Configuration for HTTP logs. If null, HTTP logs are disabled."
  type = object({
    log_retention_in_mb   = number
    log_retention_in_days = optional(number, 7)
  })
}

variable "health_check_path" {
  description = "The health check path for the app service. E.g /healthcheck"
  nullable    = true
  default     = null
}

variable "whitelist_ips" {
  default     = []
  description = "List of IP addresses to whitelist for the app service. If empty, no IP restrictions are applied."
  type        = list(string)
}

variable "whitelist_ips_scm" {
  default     = []
  description = "List of IP addresses to whitelist for the SCM (Kudu) service. If empty, no IP restrictions are applied."
  type        = list(string)
}

variable "app_environments" {
  default     = {}
  description = "Key-value pairs of environment variables to set in the app service."
}

variable "sku_name" {
  default     = "B1"
  description = "The SKU name for the app service plan. Default is B1 (Basic)."
}

variable "ARM_SUBSCRIPTION_ID" {
  nullable    = false
  description = "The Azure subscription ID for the deployment. Set in the CI/CD pipeline."
}

variable "certificate_blob_b64" {
  nullable    = true
  default     = null
  description = "Base64 encoded PFX certificate blob for custom domain SSL binding. If null, the certificate will be created using ACME."
  type        = string
  validation {
    condition     = can(regex("^[A-Za-z0-9+/=]+$", var.certificate_blob_b64)) || var.certificate_blob_b64 == null
    error_message = "The certificate_blob_b64 must be a valid Base64 encoded string or null."
  }
}

variable "docker" {
  nullable    = false
  description = "Docker image configuration for the app service."
  default = {
    image             = "nginx"
    tag               = "latest"
    registry_url      = "docker.io"
    registry_username = null
    registry_password = null
  }
  type = object({
    image             = string
    tag               = optional(string, "latest")
    registry_url      = optional(string, "docker.io")
    registry_username = optional(string, null)
    registry_password = optional(string, null)
  })

}
