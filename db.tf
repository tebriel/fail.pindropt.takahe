variable "postgres_username" {
  type = string
}
variable "postgres_password" {
  type = string
}

resource "azurerm_postgresql_server" "takahe" {
  name                = "takahe"
  location            = azurerm_resource_group.takahe-pindropt-fail.location
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.postgres_username
  administrator_login_password = var.postgres_password
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "takahe" {
  name                = "takahe"
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
  server_name         = azurerm_postgresql_server.takahe.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}
