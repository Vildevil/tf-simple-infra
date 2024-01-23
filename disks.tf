locals {
    temp = flatten([
        for index, instance in var.instances_configuration: [ 
            for index2, disk in instance.data_disks: {
                vm_hostname = instance.hostname
                disk_data = disk
            }
        ]
    ])


    mapped_disks = {for index, value in local.temp: "${value.vm_hostname}:${value.disk_data.lun}" => {
        vm_hostname = value.vm_hostname
        disk_data = value.disk_data
    }}
}


resource "azurerm_managed_disk" "vm_data_disks" {
    for_each = local.mapped_disks

    resource_group_name = data.azurerm_resource_group.rg-base.name
    location = data.azurerm_resource_group.rg-base.location

    storage_account_type = "Premium_LRS"
    disk_size_gb = each.value.disk_data.size

    name = "dd-${each.value.vm_hostname}-LUN${each.value.disk_data.lun}"
    create_option = "Empty"
}


resource "azurerm_virtual_machine_data_disk_attachment" "disk_attach" {
    for_each = local.mapped_disks
    lun = each.value.disk_data.lun
    managed_disk_id = azurerm_managed_disk.vm_data_disks[each.key].id
    virtual_machine_id = azurerm_windows_virtual_machine.vm-instances[each.value.vm_hostname].id
    caching = "ReadWrite"

    depends_on = [ azurerm_managed_disk.vm_data_disks, azurerm_windows_virtual_machine.vm-instances ]
}