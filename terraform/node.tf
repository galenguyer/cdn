resource "azurerm_virtual_network" "node-vnet" {
  count               = var.node_count
  name                = "${element(var.node_locations, count.index)}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = element(var.node_locations, count.index)
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "node-subnet" {
  count                = var.node_count
  name                 = "${element(var.node_locations, count.index)}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = element(azurerm_virtual_network.node-vnet.*.name, count.index)
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "node-ip" {
  count               = var.node_count
  name                = "${element(var.node_locations, count.index)}-ip-01"
  location            = element(var.node_locations, count.index)
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "cdn-galenguyer-01"
}

resource "azurerm_network_security_group" "node-nsg" {
  count               = var.node_count
  name                = "${element(var.node_locations, count.index)}-nsg-01"
  location            = element(var.node_locations, count.index)
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "node-nic" {
  count               = var.node_count
  name                = "${element(var.node_locations, count.index)}-nic-01"
  location            = element(var.node_locations, count.index)
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${element(var.node_locations, count.index)}-nic-config-01"
    subnet_id                     = element(azurerm_subnet.node-subnet.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.node-ip.*.id, count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "node-nic-nsg-association" {
  count                     = var.node_count
  network_interface_id      = element(azurerm_network_interface.node-nic.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.node-nsg.*.id, count.index)
}

resource "azurerm_linux_virtual_machine" "node" {
  count                 = var.node_count
  name                  = "${element(var.node_locations, count.index)}-vm-01"
  location              = element(var.node_locations, count.index)
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [element(azurerm_network_interface.node-nic.*.id, count.index)]
  size                  = var.vm_size

  os_disk {
    name                 = "${element(var.node_locations, count.index)}-vm-osdisk-01"
    caching              = "ReadWrite"
    storage_account_type = var.vm_disk_type
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  admin_username                  = var.username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

resource "azurerm_traffic_manager_endpoint" "node-endpoint" {
  count               = var.node_count
  name                = "cdn-${element(var.node_locations, count.index)}-01"
  resource_group_name = azurerm_resource_group.rg.name
  profile_name        = azurerm_traffic_manager_profile.hg80.name
  type                = "azureEndpoints"
  target_resource_id  = element(azurerm_public_ip.node-ip.*.id, count.index)
}
