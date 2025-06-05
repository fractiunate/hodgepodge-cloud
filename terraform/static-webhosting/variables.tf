variable "resource_group_name" {
  description = "The name of the resource group for the static web hosting."
}

variable "location" {
  description = "The Azure region where the static web hosting will be deployed."
  default     = "West Europe"
}

variable "static_web_app_name" {
  description = "The name of the static web app."
  default     = "example-static-web-app"
}

variable "stage" {
  description = "The stage of the deployment (e.g., dev, prod)."
  default     = "dev"
}

variable "project" {
  description = "The name of the project for tagging purposes."
  default     = "static-webhosting"
}

variable "sku_tier" {
  description = "The SKU tier for the static web app."
  default     = "Free"
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "The SKU tier must be one of: Free, Standard."
  }
}

variable "app_settings" {
  description = "A map of environment variables for the static web app."
  type        = map(string)
  default     = {}
}

