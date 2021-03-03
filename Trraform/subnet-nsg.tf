# Create public subnet for hosting bastion/public VMs.
resource "azurerm_subnet" "public_subnet" {
  name                      = "${var.resource_prefix}-pblc-snet"
  resource_group_name       = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefixes            = ["10.0.1.0/24"]
  #network_security_group_id = "${azurerm_network_security_group.public_nsg.id}"
}

# Create network security group and SSH rule for public subnet.
resource "azurerm_network_security_group" "public_nsg" {
  name                = "${var.resource_prefix}-pblc-nsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  # Allow SSH traffic in from Internet to public subnet.
  security_rule {
    name                       = "allow-ssh-all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate network security group with public subnet.
resource "azurerm_subnet_network_security_group_association" "public_subnet_assoc" {
  subnet_id                 = "${azurerm_subnet.public_subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.public_nsg.id}"
}

# Create a public IP address for bastion host VM in public subnet.
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.resource_prefix}-ip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"
  allocation_method   = "Dynamic"
}

# Create network interface for bastion host VM in public subnet.
resource "azurerm_network_interface" "bastion_nic" {
  name                      = "${var.resource_prefix}-bstn-nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.resource_group.name}"
  #network_security_group_id = "${azurerm_network_security_group.public_nsg.id}"

  ip_configuration {
    name                          = "${var.resource_prefix}-bstn-nic-cfg"
    subnet_id                     = "${azurerm_subnet.public_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip.id}"
  }
}

# Create private subnet for hosting worker VMs.
resource "azurerm_subnet" "private_subnet" {
  name                      = "${var.resource_prefix}-prvt-snet"
  resource_group_name       = "${azurerm_resource_group.resource_group.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefixes            = ["10.0.2.0/24"]
  #network_security_group_id = "${azurerm_network_security_group.private_nsg.id}"
}

# Create network security group and SSH rule for private subnet.
resource "azurerm_network_security_group" "private_nsg" {
  name                = "${var.resource_prefix}-prvt-nsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.resource_group.name}"

  # Allow SSH traffic in from public subnet to private subnet.
  security_rule {
    name                       = "allow-ssh-public-subnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  # Block all outbound traffic from private subnet to Internet.
  security_rule {
    name                       = "deny-internet-all"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate network security group with private subnet.
resource "azurerm_subnet_network_security_group_association" "private_subnet_assoc" {
  subnet_id                 = "${azurerm_subnet.private_subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.private_nsg.id}"
}

# Create network interface for worker host VM in private subnet.
resource "azurerm_network_interface" "worker_nic" {
  name                      = "${var.resource_prefix}-wrkr-nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.resource_group.name}"
  #network_security_group_id = "${azurerm_network_security_group.private_nsg.id}"

  ip_configuration {
    name                          = "${var.resource_prefix}-wrkr-nic-cfg"
    subnet_id                     = "${azurerm_subnet.private_subnet.id}"
    private_ip_address_allocation = "Dynamic"
  }
}