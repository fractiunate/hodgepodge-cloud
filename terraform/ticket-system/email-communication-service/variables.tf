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
  default     = "static-webhosting"
}

variable "data_location" {
  description = "The location of the email data (a geography, not a region or data center). See https://learn.microsoft.com/en-us/azure/communication-services/concepts/privacy"
  type        = string
  default     = "Germany"
  nullable    = false
}

variable "custom_domain" {
  description = "The custom domain for the email communication service."
  type = object({
    domain_name         = string
    resource_group_name = string
    sender_usernames    = optional(list(string), ["no-reply"])
  })
  default  = null
  nullable = true
}
