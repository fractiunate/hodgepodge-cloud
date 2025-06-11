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
  alias           = "dns"
  subscription_id = var.custom_domain.dns_subscription_id != null ? var.custom_domain.dns_subscription_id : var.ARM_SUBSCRIPTION_ID
}

provider "random" {}

