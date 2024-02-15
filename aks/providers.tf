provider "azurerm" {
  features {}
  subscription_id = var.SUBSCRIPTION_ID
  skip_provider_registration = true
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.91.0"
    }
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "init_rg"
    storage_account_name = "initinfrasa"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}