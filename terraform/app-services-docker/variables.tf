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
  default     = "app-services-docker-python"
}

variable "custom_domain" {
  nullable    = true
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
