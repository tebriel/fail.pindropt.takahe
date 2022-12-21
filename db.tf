variable "postgres_username" {
  type = string
}
variable "postgres_password" {
  type = string
}

resource "azurerm_private_dns_zone" "takahe-db" {
  name                = "pindropt.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
}

resource "azurerm_subnet" "postgres" {
  name                 = "postgres"
  resource_group_name  = azurerm_resource_group.takahe-pindropt-fail.name
  virtual_network_name = azurerm_virtual_network.takahe.name
  address_prefixes     = ["10.0.9.0/24"]
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

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "pindropt.fail"
  private_dns_zone_name = azurerm_private_dns_zone.takahe-db.name
  virtual_network_id    = azurerm_virtual_network.takahe.id
  resource_group_name   = azurerm_resource_group.takahe-pindropt-fail.name
}

resource "azurerm_postgresql_flexible_server" "takahe" {
  name                   = "takahe"
  resource_group_name    = azurerm_resource_group.takahe-pindropt-fail.name
  location               = azurerm_resource_group.takahe-pindropt-fail.location
  version                = "14"
  delegated_subnet_id    = azurerm_subnet.postgres.id
  administrator_login    = var.postgres_username
  administrator_password = var.postgres_password
  private_dns_zone_id    = azurerm_private_dns_zone.takahe-db.id
  zone                   = "1"

  storage_mb = 32768

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
  sku_name   = "GP_Standard_D4s_v3"
}

resource "azurerm_postgresql_flexible_server_database" "takahe" {
  name      = "takahe"
  server_id = azurerm_postgresql_flexible_server.takahe.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
