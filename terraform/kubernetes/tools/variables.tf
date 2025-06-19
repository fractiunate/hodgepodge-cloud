variable "b64_cluster_host" {
  description = "Base64 encoded cluster host URL"
  type        = string
}

variable "b64_client_certificate" {
  description = "Base64 encoded cluster client certificate"
  type        = string
}

variable "b64_client_key" {
  description = "Base64 encoded cluster client key"
  type        = string
}

variable "b64_cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  type        = string
}

variable "custom_domain" {
  nullable = false
  type = object({
    domain_name         = string
    dns_subscription_id = optional(string, null)
    resource_group_name = optional(string, null)
  })
  validation {
    condition     = !(try(var.custom_domain.dns_subscription_id, null) != null && try(var.custom_domain.resource_group_name, null) == null)
    error_message = "If dns_subscription_id is set, both dns_subscription_id and resource_group_name must be provided."
  }
  description = "The custom domain for the app service."
}

variable "cert_manager_federated_identity_client_id" {
  description = "The client ID of the cert-manager federated identity."
  type        = string
  nullable    = false
}

variable "letsencypt_production" {
  description = "Flag to indicate if Let's Encrypt production should be used."
  type        = bool
  default     = false
}

variable "tls_redirect" {
  description = "Flag to indicate if TLS redirect should be enabled."
  type        = bool
  default     = true
}
