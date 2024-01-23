output "vnet" {
    value = azurerm_virtual_network.vnet
}

output "rg" {
    value = data.azurerm_resource_group.rg-base
}
