terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "docker_testing" {
  name     = "docker-test-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "docker_testing" {
  name                = "docker-test-vnet"
  location            = azurerm_resource_group.docker_testing.location
  resource_group_name = azurerm_resource_group.docker_testing.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "docker_testing" {
  name                 = "resource-sub"
  resource_group_name  = azurerm_resource_group.docker_testing.name
  virtual_network_name = azurerm_virtual_network.docker_testing.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "docker_testing" {
  name                = "my-public-ip"
  location            = azurerm_resource_group.docker_testing.location
  resource_group_name = azurerm_resource_group.docker_testing.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "docker_testing" {
  name                = "docker-test-nic"
  location            = azurerm_resource_group.docker_testing.location
  resource_group_name = azurerm_resource_group.docker_testing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.docker_testing.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.docker_testing.id
  }
}

resource "azurerm_linux_virtual_machine" "docker_testing" {
  name                = "docker-test-vm"
  resource_group_name = azurerm_resource_group.docker_testing.name
  location            = azurerm_resource_group.docker_testing.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.docker_testing.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }


  secure_boot_enabled = true
  vtpm_enabled        = true
}