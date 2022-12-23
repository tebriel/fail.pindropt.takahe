resource "azurerm_storage_account" "media" {
  name                = "takahepindroptfail"
  resource_group_name = azurerm_resource_group.takahe-pindropt-fail.name
  location            = azurerm_resource_group.takahe-pindropt-fail.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  enable_https_traffic_only = false
  account_replication_type  = "LRS"
  nfsv3_enabled             = true
  is_hns_enabled            = true
}
resource "azurerm_storage_account_network_rules" "default" {
  storage_account_id = azurerm_storage_account.media.id

  default_action             = "Allow"
  ip_rules                   = [azurerm_public_ip.ip.ip_address]
  virtual_network_subnet_ids = [azurerm_subnet.default.id]
}
