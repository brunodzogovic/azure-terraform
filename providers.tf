# using the new Graph API will also open for other possibilities when it comes 
# to automation of other resources in Azure such as Conditional Access, Security 
# settings, and other settings within Azure.

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.31.1"
    }
  }
}

variable "tenant_id" {}
variable "client_secret" {}
variable "client_id" {}
variable "subscription_id" {}

provider "azuread" {
  tenant_id     = var.tenant_id
  client_secret = var.client_secret
  client_id     = var.client_id
}

provider "azurerm" {
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_secret   = var.client_secret
  client_id       = var.client_id
}

provider "random" {}
