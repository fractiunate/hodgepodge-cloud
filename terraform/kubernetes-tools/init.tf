terraform {
  required_version = ">= 1.10.0"
  backend "azurerm" {
    # resource_group_name  = "set-in-cicd"
    # storage_account_name = "set-in-cicd"
    # container_name       = "set-in-cicd"
    # key                  = "set-in-cicd"
  }
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = base64decode(var.cluster_host)
    client_certificate     = base64decode(var.client_certificate)
    client_key             = base64decode(var.client_key)
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
  experiments = {
    manifest = false
  }
}

provider "azurerm" {
  #   skip_provider_registration = "true"
  features {}
}
