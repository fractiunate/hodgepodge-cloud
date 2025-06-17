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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }

  }
}

provider "kubernetes" {
  host                   = chomp(base64decode(var.b64_cluster_host))
  client_certificate     = chomp(base64decode(var.b64_client_certificate))
  client_key             = chomp(base64decode(var.b64_client_key))
  cluster_ca_certificate = chomp(base64decode(var.b64_cluster_ca_certificate))
}

provider "helm" {
  kubernetes = {
    host                   = chomp(base64decode(var.b64_cluster_host))
    client_certificate     = chomp(base64decode(var.b64_client_certificate))
    client_key             = chomp(base64decode(var.b64_client_key))
    cluster_ca_certificate = chomp(base64decode(var.b64_cluster_ca_certificate))
  }
  experiments = {
    manifest = false
  }
}

provider "azurerm" {
  #   skip_provider_registration = "true"
  features {}
}

output "b64_cluster_host" {
  value = var.b64_cluster_host
}

output "cluster_host" {
  value = chomp(base64decode(var.b64_cluster_host))
}
