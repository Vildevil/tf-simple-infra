locals {
    windows_temp = flatten([
        for index, instance in var.windows_instances_configuration: [ 
            for index2, disk in instance.data_disks: {
                vm_hostname = instance.hostname
                disk_data = disk
            }
        ]
    ])


    windows_mapped_disks = {for index, value in local.windows_temp: "windows:${value.vm_hostname}:${value.disk_data.lun}" => {
        vm_hostname = value.vm_hostname
        disk_data = value.disk_data
    }}

    linux_temp = flatten([
        for index, instance in var.linux_instances_configuration: [ 
            for index2, disk in instance.data_disks: {
                vm_hostname = instance.hostname
                disk_data = disk
            }
        ]
    ])

    linux_mapped_disks = {for index, value in local.linux_temp: "linux:${value.vm_hostname}:${value.disk_data.lun}" => {
        vm_hostname = value.vm_hostname
        disk_data = value.disk_data
    }}

}


resource "azurerm_managed_disk" "windows_vm_data_disks" {
    for_each = local.windows_mapped_disks

    resource_group_name = data.azurerm_resource_group.rg-base.name
    location = data.azurerm_resource_group.rg-base.location

    storage_account_type = "StandardSSD_LRS"
    disk_size_gb = each.value.disk_data.size

    name = "dd-${each.value.vm_hostname}-LUN${each.value.disk_data.lun}"
    create_option = "Empty"
}


resource "azurerm_managed_disk" "linux_vm_data_disks" {
    for_each = local.linux_mapped_disks

    resource_group_name = data.azurerm_resource_group.rg-base.name
    location = data.azurerm_resource_group.rg-base.location

    storage_account_type = "StandardSSD_LRS"
    disk_size_gb = each.value.disk_data.size

    name = "dd-${each.value.vm_hostname}-LUN${each.value.disk_data.lun}"
    create_option = "Empty"
}


resource "azurerm_virtual_machine_data_disk_attachment" "windows_disk_attach" {
    for_each = local.windows_mapped_disks
    lun = each.value.disk_data.lun
    managed_disk_id = azurerm_managed_disk.windows_vm_data_disks[each.key].id
    virtual_machine_id = azurerm_windows_virtual_machine.win_vm_instances[each.value.vm_hostname].id
    caching = "ReadWrite"

    depends_on = [ azurerm_managed_disk.windows_vm_data_disks, azurerm_windows_virtual_machine.win_vm_instances ]
}


resource "azurerm_virtual_machine_data_disk_attachment" "linux_disk_attach" {
    for_each = local.linux_mapped_disks
    lun = each.value.disk_data.lun
    managed_disk_id = azurerm_managed_disk.linux_vm_data_disks[each.key].id
    virtual_machine_id = azurerm_linux_virtual_machine.linux_vm_instances[each.value.vm_hostname].id
    caching = "ReadWrite"

    depends_on = [ azurerm_managed_disk.linux_vm_data_disks, azurerm_linux_virtual_machine.linux_vm_instances ]
}