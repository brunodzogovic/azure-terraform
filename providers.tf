# The terraform section at the beginning is used to specify the version of the 
# provider that we want to use, while the 
# azuread_group resource defines our group.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

# Configuring the provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "North Europe"
}

