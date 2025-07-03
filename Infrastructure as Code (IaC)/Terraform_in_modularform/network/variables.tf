variable "location" {
    type = string
    default = "eastus2"
    description = "location for vnet & subnet deployments"
    validation {
      condition = contains(["eastus2", "centralus"], lower(var.location))
      error_message = "Unsupported Azure Region specified for network. Only East US2 and Central US Azure Regions are supported"
    }
  
}

variable "rg_Name" {
    type = string
    default = ""
    description = "Resource group name to deploy resources"
  
}

variable "vnet_Name" {
    type = string
    default = ""
    description = "Name of the vnet to create"
    validation {
      condition = length(var.vnet_Name) > 6 && can(regex("dev", lower(var.vnet_Name)))
      error_message = "The vnet_Name must be valid name, should contain \"dev\". This can be configured in variables.tf file to streamline according to the environment."
    }
  
}

variable "subnet_NameList" {
    type = list(string)
    default = [ "" ]
    description = "List of subnet names inside the vnet"
    validation {
      condition = alltrue([
        for snet in var.subnet_NameList : length(snet) > 6 && can(regex("dev", lower(snet))) || can(regex("gate", lower(snet)))
      ])
      error_message = "The subnet_NameList must be valid name, should contain \" dev \". This can be configured in variables.tf file to streamline according to the environment."
    }
  
}

variable "subnet_AddressList" {
    type = litst(string)
    default = [""]
    description = "The address prefix to use for the subnet."
  
}