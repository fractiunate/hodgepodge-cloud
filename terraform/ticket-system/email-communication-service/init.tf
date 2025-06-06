terraform {
  backend "azurerm" {
    # resource_group_name  = "set-in-cicd"
    # storage_account_name = "set-in-cicd"
    # container_name       = "set-in-cicd"
    # key                  = "set-in-cicd"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13"
    }
    azapi = {
      source  = "azure/azapi"
      version = "2.4.0"
    }
  }
  required_version = ">= 1.10.0"
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  for_each        = { for provider_config in toset(["dns"]) : provider_config => provider_config if var.custom_domain.dns_subscription_id != null }
  alias           = "dns"
  subscription_id = var.custom_domain.dns_subscription_id
}

provider "azapi" {}

provider "random" {}

