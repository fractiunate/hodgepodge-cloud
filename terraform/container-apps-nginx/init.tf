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
  }
  required_version = ">= 1.10.0"
}

provider "azurerm" {
  features {}
}

provider "random" {}

resource "azurerm_resource_provider_registration" "app" {
  count = var.provider_registration_ms_app ? 1 : 0
  name  = "Microsoft.App"
}
