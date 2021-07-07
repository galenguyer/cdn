terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.66"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "cdn"
  location = "eastus"
}

resource "azurerm_traffic_manager_profile" "hg80" {
  name                = "hg80"
  resource_group_name = azurerm_resource_group.rg.name

  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "hg80"
    ttl           = 60
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

# resource "azurerm_virtual_network" "vnet" {
#   name                = "${azurerm_resource_group.rg.name}-vnet"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_subnet" "subnet" {
#   name                 = "${azurerm_resource_group.rg.name}-subnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.0.0/16"]
# }

# resource "azurerm_network_security_group" "nsg" {
#   name                = "${azurerm_resource_group.rg.name}-nsg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   # normal stuff
#   security_rule {
#     name                       = "SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   security_rule {
#     name                       = "HTTP"
#     priority                   = 1002
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   security_rule {
#     name                       = "HTTPS"
#     priority                   = 1003
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "443"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "nic-subnet-association" {
#   subnet_id                 = azurerm_subnet.subnet.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# resource "azurerm_public_ip" "ip" {
#   count               = var.worker_count
#   name                = "${azurerm_resource_group.rg.name}-ip-${format("%02d", count.index + 1)}"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   domain_name_label   = "${azurerm_resource_group.rg.name}-${var.unique_id}-${format("%02d", count.index + 1)}"
# }

# resource "azurerm_network_interface" "nic" {
#   count               = var.worker_count
#   name                = "${azurerm_resource_group.rg.name}-nic-${format("%02d", count.index + 1)}"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "${azurerm_resource_group.rg.name}-nic-config-${format("%02d", count.index + 1)}"
#     subnet_id                     = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = element(azurerm_public_ip.ip.*.id, count.index)
#   }
# }

# resource "azurerm_linux_virtual_machine" "vm" {
#   count                 = var.worker_count
#   name                  = "${azurerm_resource_group.rg.name}-vm-${format("%02d", count.index + 1)}"
#   location              = azurerm_resource_group.rg.location
#   resource_group_name   = azurerm_resource_group.rg.name
#   network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
#   size                  = var.vm_size

#   os_disk {
#     name                 = "${azurerm_resource_group.rg.name}-vm-osdisk-${format("%02d", count.index + 1)}"
#     caching              = "ReadWrite"
#     storage_account_type = var.vm_disk_type
#   }

#   source_image_reference {
#     publisher = "Debian"
#     offer     = "debian-10"
#     sku       = "10"
#     version   = "latest"
#   }

#   admin_username                  = var.username
#   disable_password_authentication = true

#   admin_ssh_key {
#     username   = var.username
#     public_key = file("~/.ssh/id_rsa.pub")
#   }
# }
