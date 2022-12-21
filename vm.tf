resource "azurerm_virtual_network" "takahe" {
  name                = "takahe.pindropt.fail-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.takahe-pindropt-fail.name
  virtual_network_name = azurerm_virtual_network.takahe.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_public_ip" "ip" {
  name                = "ip"
  location            = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "takahe" {
  name                = "takahe"
  location            = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_virtual_machine" "takahe" {
  name                  = "takahe"
  location              = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name   = azurerm_resource_group.takahe-pindropt-fail.name
  network_interface_ids = [azurerm_network_interface.takahe.id]
  vm_size               = "Standard_B2s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  boot_diagnostics {
    enabled     = true
    storage_uri = ""
  }

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    os_type           = "Linux"
    name              = "takahe_osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "takahe"
    admin_username = "tebriel"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCV5VtRYn2N8LY021ctMQj7nk1aUu51iGlRPEHCiJAFTT/wyVS3eA43Lhoup+UhQe3KqhTOA6zxUyq4dgivLTLm8+qWsm4FFoDvgK73fKNQh+TrUwY7507imIhwYmYLfiSN7aB5ksMgPhX/cZSl8OIaimjNdIRBEMEEUErhDh52NKvcuaCECNrDHhEse6O46HW9hQOQ3jxQ6J05NbVAgJefGPH4t+GqItrq9ZEhWnciFnlo/PFIQiyYOliLvkEFzQ8I+njecl4/SsR7pPs9Ve3fMncWqSqSRJm0APvHk/zoMp3B+KT6IjIdocnTu0JDtoi/FwNIfAlECHnYfx3FsacNO9qlDr0kYFtIzuXPvT1khclcaZlYPuq2PVX4eywvCH2uYsT3GZqbfOpwDOL3PDhVjGDN6UD5drJotUh29NTzy7ALAN8RTr/Am2PsjjngV0rzADkSwBW50dihgj5fxyuTFtHY/UpwYg2mFK24v1W7zlXkRVuRdDDZddMgG3cxe/DSN8EkEP1yyvwzlAAfFsfTh87Bd+egmWWVxhmmJk4cENngv9+5fPgVz8CDvcbPouTdRrTcVy1uMjo1YcQrBHaOlwL90ivrAtxPZ6xsZfpOBvLJoW+Iae22rTVrIIPCpgUFXKLLZ85VbE+zof2qoMAA7lIogvzXNEKdmunCp0HOKw=="
      path     = "/home/tebriel/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_network_security_group" "takahe-nsg" {
  name                = "takahe-nsg"
  location            = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  resource_group_name         = azurerm_resource_group.takahe-pindropt-fail.name
  network_security_group_name = azurerm_network_security_group.takahe-nsg.name
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "http" {
  name                        = "HTTP"
  resource_group_name         = azurerm_resource_group.takahe-pindropt-fail.name
  network_security_group_name = azurerm_network_security_group.takahe-nsg.name
  priority                    = 330
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "https" {
  name                        = "HTTPS"
  resource_group_name         = azurerm_resource_group.takahe-pindropt-fail.name
  network_security_group_name = azurerm_network_security_group.takahe-nsg.name
  priority                    = 320
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
