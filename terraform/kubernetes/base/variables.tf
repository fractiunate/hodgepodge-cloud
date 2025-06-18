variable "resource_group_name" {
  description = "The name of the resource group for the static web hosting."
}

variable "location" {
  description = "The Azure region where the static web hosting will be deployed."
  default     = "West Europe"
}

variable "stage" {
  description = "The stage of the deployment (e.g., dev, prod)."
  default     = "dev"
}

variable "project" {
  description = "The name of the project for tagging purposes."
  default     = "container-apps-nginx"
}

variable "ARM_SUBSCRIPTION_ID" {
  nullable    = false
  description = "The Azure subscription ID for the deployment. Set in the CI/CD pipeline."
}

variable "custom_domain" {
  nullable = true
  default  = null
  type = object({
    domain_name         = string
    dns_subscription_id = optional(string, null)
    resource_group_name = optional(string, null)
  })
  validation {
    condition     = (try(var.custom_domain.dns_subscription_id, null) != null && try(var.custom_domain.resource_group_name, null) != null)
    error_message = "If dns_subscription_id is set, both dns_subscription_id and resource_group_name must be provided."
  }
  description = "The custom domain for the app service."
}
