resource "azurerm_storage_account" "media" {
  name                = "takahepindropt"
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
  location            = azurerm_resource_group.takahe-pindropt-fail.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  enable_https_traffic_only = false
  account_replication_type  = "LRS"
  nfsv3_enabled             = true
  is_hns_enabled            = true
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.default.id]
  }
}

resource "azurerm_storage_container" "media" {
  name                  = "media"
  storage_account_name  = azurerm_storage_account.media.name
  container_access_type = "private"
}
