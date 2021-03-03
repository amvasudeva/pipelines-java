## <https://www.terraform.io/docs/providers/azurerm/r/windows_virtual_machine.html>

resource "azurerm_windows_virtual_machine" "example" {
  name                = "${var.resource_prefix}-machine"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.bastion_nic.id,
  ]

  os_disk {
    name              = "${var.resource_prefix}-bstn-dsk001"
    caching           = "ReadWrite"
    #create_option     = "FromImage"
    #managed_disk_type = "Standard_LRS"
	storage_account_type = "Standard_LRS"
  }

  #boot_diagnostics {
   # enabled     = "true"
   # storage_uri = "${azurerm_storage_account.storage_account.primary_blob_endpoint}"
  #}

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

  resource "tls_private_key" "tst_key" {
  algorithm = "RSA"
  rsa_bits = 4096
  }

# Create worker host VM.
resource "azurerm_linux_virtual_machine" "worker_vm" {
  name                  = "${var.resource_prefix}-wrkr-vm001"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.worker_nic.id}"]
  size               = "Standard_DS1_v2"

  os_disk {
    name              = "${var.resource_prefix}-wrkr-dsk001"
    caching           = "ReadWrite"
    #create_option     = "FromImage"
    #managed_disk_type = "Standard_LRS"
	storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  computer_name  = "${var.resource_prefix}-wrkr-vm001"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
      username       = "azureuser"
      public_key     = tls_private_key.tst_key.public_key_openssh
    }
	
 # os_profile_linux_config {
  #  disable_password_authentication = true
#}

 # boot_diagnostics {
  ##  enabled     = "true"
   # storage_uri = "${azurerm_storage_account.storage_account.primary_blob_endpoint}"
  #}
}
