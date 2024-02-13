locals {
  linux_mapped_vm = {for index, value in var.linux_instances_configuration: value.name => value}
  linux_vm_index = {for index, value in var.linux_instances_configuration: value.name => index}
}


resource "azurerm_network_interface" "linux_nic_instances" {
    for_each = local.linux_mapped_vm

    name = "nic-${var.base_name}-${format("%02s", local.linux_vm_index[each.key] + 1)}"
    resource_group_name = data.azurerm_resource_group.rg-base.name
    location = data.azurerm_resource_group.rg-base.location

    ip_configuration {
        name = "pip-${var.base_name}-${local.linux_vm_index[each.key]}"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.subs[local.linux_mapped_vm[each.key].subnet].id
    }

    dns_servers = var.global.dns_servers
    

    depends_on = [ azurerm_subnet.subs ]
}


resource "azurerm_linux_virtual_machine" "linux_vm_instances" {
    for_each = local.linux_mapped_vm

    name = each.value.name
    computer_name = each.value.hostname
    resource_group_name = data.azurerm_resource_group.rg-base.name
    location = data.azurerm_resource_group.rg-base.location

    admin_username = each.value.username

    admin_ssh_key {
      username = each.value.username
      public_key = each.value.public_ssh_key
    }

    os_disk {
        name = "osd-${each.value.name}"
        storage_account_type = "Standard_LRS"
        caching = "ReadWrite"
        disk_size_gb = each.value.os_disk_size
    }


    size = each.value.type
    network_interface_ids = [ azurerm_network_interface.linux_nic_instances[each.key].id ]

    source_image_reference {
      version = each.value.image_reference.version
      publisher = each.value.image_reference.publisher
      offer = each.value.image_reference.offer
      sku = each.value.image_reference.sku
    }

    depends_on = [ azurerm_network_interface.linux_nic_instances ]
}