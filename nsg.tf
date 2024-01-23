resource "azurerm_network_security_group" "default_sg" {
    resource_group_name = data.azurerm_resource_group.rg-base.name
    location = data.azurerm_resource_group.rg-base.location
    name = "nsg-${var.base_name}-01"
}