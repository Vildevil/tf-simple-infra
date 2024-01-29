resource "azurerm_virtual_network" "vnet" {
  resource_group_name = data.azurerm_resource_group.rg-base.name
  name = "vnet-${var.base_name}-01"
  address_space = var.network_configuration.address_space
  location =  data.azurerm_resource_group.rg-base.location
  dns_servers = var.global.dns_servers
}



resource "azurerm_subnet" "subs" {
  for_each = toset(var.network_configuration.subnets)
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.rg-base.name
  name = "snet-${var.base_name}-${format("%02s", index(var.network_configuration.subnets, each.key) + 1)}"
  address_prefixes = [each.key]
}

resource "azurerm_subnet_network_security_group_association" "subnets-default-nsg" {
  for_each = azurerm_subnet.subs

  subnet_id = each.value.id
  network_security_group_id = azurerm_network_security_group.default_sg.id
}