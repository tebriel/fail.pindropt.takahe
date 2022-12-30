data "azurerm_resource_group" "pindropt-fail" {
  name = "pindropt.fail"
}

data "azurerm_dns_zone" "pindropt-fail" {
  name                = "pindropt.fail"
  resource_group_name = data.azurerm_resource_group.pindropt-fail.name
}

resource "azurerm_dns_a_record" "takahe-pindropt-fail-ipv4" {
  name                = "takahe"
  zone_name           = data.azurerm_dns_zone.pindropt-fail.name
  resource_group_name = data.azurerm_resource_group.pindropt-fail.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.ipv4.id
}

resource "azurerm_dns_aaaa_record" "takahe-pindropt-fail-ipv6" {
  name                = "takahe"
  zone_name           = data.azurerm_dns_zone.pindropt-fail.name
  resource_group_name = data.azurerm_resource_group.pindropt-fail.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.ipv6.id
}

resource "azurerm_dns_a_record" "pindropt-fail-ipv4" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.pindropt-fail.name
  resource_group_name = data.azurerm_resource_group.pindropt-fail.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.ipv4.id
}

resource "azurerm_dns_aaaa_record" "pindropt-fail-ipv6" {
  name                = "@"
  zone_name           = data.azurerm_dns_zone.pindropt-fail.name
  resource_group_name = data.azurerm_resource_group.pindropt-fail.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.ipv6.id
}
