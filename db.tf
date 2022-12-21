variable "postgres_username" {
  type = string
}
variable "postgres_password" {
  type = string
}

resource "azurerm_postgresql_flexible_server" "takahe" {
  name                   = "takahe"
  resource_group_name    = azurerm_resource_group.takahe-pindropt-fail.name
  location               = azurerm_resource_group.takahe-pindropt-fail.location
  version                = "14"
  delegated_subnet_id    = azurerm_subnet.default.id
  administrator_login    = var.postgres_username
  administrator_password = var.postgres_password
  zone                   = "1"

  storage_mb = 32768

  sku_name = "GP_Standard_D4s_v3"
}

resource "azurerm_postgresql_flexible_server_database" "takahe" {
  name      = "takahe"
  server_id = azurerm_postgresql_flexible_server.takahe.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
