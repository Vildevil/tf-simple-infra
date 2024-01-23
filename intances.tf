locals {
  mapped_vm = {for index, value in var.instances_configuration: value.hostname => value}
  vm_index = {for index, value in var.instances_configuration: value.hostname => index}
}


output "demo" {
  value = local.mapped_vm
}

resource "azurerm_network_interface" "nic-instances" {
    for_each = local.mapped_vm

    name = "nic-${var.base_name}-${format("%02s", local.vm_index[each.key] + 1)}"
    resource_group_name = data.azurerm_resource_group.rg-base.name
    location = data.azurerm_resource_group.rg-base.location

    ip_configuration {
        name = "pip-${var.base_name}-${local.vm_index[each.key]}"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.subs[local.mapped_vm[each.key].subnet].id
    }

    dns_servers = var.global.dns_servers
    

    depends_on = [ azurerm_subnet.subs ]
}


resource "azurerm_windows_virtual_machine" "vm-instances" {
    for_each = local.mapped_vm

    name = each.value.name
    computer_name = each.value.hostname
    resource_group_name = data.azurerm_resource_group.rg-base.name
    location = data.azurerm_resource_group.rg-base.location

    admin_password = each.value.password
    admin_username = each.value.username
    os_disk {
        name = "osd-${each.value.name}"
        storage_account_type = "Standard_LRS"
        caching = "ReadWrite"
        disk_size_gb = each.value.os_disk_size
    }

    license_type = each.value.licence_type

    size = each.value.type
    network_interface_ids = [ azurerm_network_interface.nic-instances[each.key].id ]

    source_image_reference {
      version = each.value.image_reference.version
      publisher = each.value.image_reference.publisher
      offer = each.value.image_reference.offer
      sku = each.value.image_reference.sku
    }

    depends_on = [ azurerm_network_interface.nic-instances ]
}