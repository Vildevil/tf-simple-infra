variable "resources_group_name" {
  type = string
}

variable "base_name" {
  type = string 
}

variable "global" {
  type = object({
    dns_servers = list(string)
  })
}



variable "network_configuration" {
  type = object({
    address_space = list(string)
    subnets = list(string)
  })
}

variable "windows_instances_configuration" {
  type = list(object({
    hostname = string
    name = string
    type = string
    username = string
    password = string
    subnet = string
    os_disk_size = number
    licence_type = string
    data_disks = list(object({
      lun = string
      size = number
    }))

    image_reference = object({
      publisher = string
      version = string
      sku = string
      offer = string
    })
  }))
}


variable "linux_instances_configuration" {
  type = list(object({
    name = string
    hostname = string

    type = string

    username = string
    public_ssh_key = string

    subnet = string

    os_disk_size = number

    data_disks = list(object({
      lun = string
      size = number
    }))

    image_reference = object({
      publisher = string
      version = string
      sku = string
      offer = string
    })
  }))
}