resource "azurerm_storage_account" "media" {
  name                = "takahepindroptfail"
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name

  location                 = azurerm_resource_group.takahe-pindropt-fail.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = [azurerm_subnet.default.id]
  }
}
