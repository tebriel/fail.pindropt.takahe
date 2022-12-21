resource "azurerm_public_ip" "ipv4" {
  name                = "ipv4"
  location            = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_public_ip" "ipv6" {
  name                = "ipv6"
  location            = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
  allocation_method   = "Static"
  ip_version          = "IPv6"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}

resource "azurerm_lb" "takahe-pindropt-fail" {
  name                = "lb"
  location            = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "ipv4"
    public_ip_address_id = azurerm_public_ip.ipv4.id
  }

  frontend_ip_configuration {
    name                 = "ipv6"
    public_ip_address_id = azurerm_public_ip.ipv6.id
  }
}

resource "azurerm_lb_nat_rule" "https" {
  resource_group_name            = azurerm_resource_group.takahe-pindropt-fail.name
  loadbalancer_id                = azurerm_lb.takahe-pindropt-fail.id
  name                           = "https"
  protocol                       = "Tcp"
  frontend_port_start            = 443
  frontend_port_end              = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_public_ip.ipv4.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.takahe.id
}

resource "azurerm_lb_nat_rule" "https-ipv6" {
  resource_group_name            = azurerm_resource_group.takahe-pindropt-fail.name
  loadbalancer_id                = azurerm_lb.takahe-pindropt-fail.id
  name                           = "https-ipv6"
  protocol                       = "Tcp"
  frontend_port_start            = 443
  frontend_port_end              = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_public_ip.ipv6.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.takahe.id
}

resource "azurerm_lb_nat_rule" "http" {
  resource_group_name            = azurerm_resource_group.takahe-pindropt-fail.name
  loadbalancer_id                = azurerm_lb.takahe-pindropt-fail.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_public_ip.ipv4.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.takahe.id
}

resource "azurerm_lb_nat_rule" "http-ipv6" {
  resource_group_name            = azurerm_resource_group.takahe-pindropt-fail.name
  loadbalancer_id                = azurerm_lb.takahe-pindropt-fail.id
  name                           = "http-ipv6"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_public_ip.ipv6.name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.takahe.id
}


resource "azurerm_lb_backend_address_pool" "takahe" {
  loadbalancer_id = azurerm_lb.takahe-pindropt-fail.id
  name            = "takahe"
}

resource "azurerm_lb_backend_address_pool_address" "takahe-vm" {
  name                    = "takahe-vm"
  backend_address_pool_id = azurerm_lb_backend_address_pool.takahe.id
  virtual_network_id      = azurerm_virtual_network.takahe.id
  ip_address              = azurerm_network_interface.takahe.private_ip_address
}
