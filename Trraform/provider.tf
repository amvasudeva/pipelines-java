# - - - - - - - - - - - - - - - - - - - - -
# Configure the Azure RM Provider  
#  
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}
 
provider "azurerm" {
  
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  features {}
}