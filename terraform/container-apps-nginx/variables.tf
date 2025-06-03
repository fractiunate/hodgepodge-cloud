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
  default     = "container-apps"
}
