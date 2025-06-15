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
    acme = {
      source  = "ruokei/acme"
      version = "0.0.8"
    }
  }
  required_version = ">= 1.10.0"
}

provider "azurerm" {
  features {}
}

provider "random" {}
