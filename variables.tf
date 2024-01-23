variable "resources_group_name" {
  type = string
}

variable "base_name" {
  type = string 
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
    type = string
    username = string
    password = string
    subnet = string
    os_disk_size = number
    data_disks = list(object({
      lun = string
      name = string
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