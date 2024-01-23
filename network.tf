resource "azurerm_virtual_network" "vnet" {
  resource_group_name = data.azurerm_resource_group.rg-base.name
  name = "vnet-${var.base_name}-01"
  address_space = var.network_configuration.address_space
  location =  data.azurerm_resource_group.rg-base.location
}



resource "azurerm_subnet" "subs" {
  for_each = toset(var.network_configuration.subnets)
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = data.azurerm_resource_group.rg-base.name
  name = "subnet-${var.base_name}-${format("%02s", index(var.network_configuration.subnets, each.key) + 1)}"
  address_prefixes = [each.key]
}