# Create a resource group if it doesn’t exist.
resource "azurerm_resource_group" "resource_group" {
  name     = "IDOP-TST-RG01"
  location = "eastus"
}

# Create storage account if it doesn’t exist for boot diagnostics.
resource "azurerm_storage_account" "storage_account" {
  name                     = "idoptest123"
  location                 = "eastus"
  resource_group_name      = azurerm_resource_group.resource_group.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# Create virtual network with public and private subnets.
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
}

