terraform {
  required_providers {
    azurerm = {
      version = "= 3.54.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
provider "azurerm" {
  features {}
}
