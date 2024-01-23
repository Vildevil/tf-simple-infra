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

variable "instances_configuration" {
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