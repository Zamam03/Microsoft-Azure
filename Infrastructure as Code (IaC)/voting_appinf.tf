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

locals {
  location          = "eastus"
  cluster_name     = "voting-app-aks"
  dns_prefix       = "votingappaks"
  acr_name         = "votingappacr${substr(md5(local.cluster_name), 0, 8)}"
  vnet_name        = "voting-app-vnet"
  subnet_name      = "aks-subnet"
  vm_name          = "voting-app-management-vm"
  admin_username   = "azureuser"
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_resource_group" "voting_app" {
  name     = "voting-app-rg"
  location = local.location
}

resource "azurerm_virtual_network" "voting_app" {
  name                = local.vnet_name
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.voting_app.name
  virtual_network_name = azurerm_virtual_network.voting_app.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "voting_app" {
  name                = "voting-app-nsg"
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "vm" {
  name                = "voting-app-vm-ip"
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name
  allocation_method   = "Dynamic"
  domain_name_label   = "votingappvm${substr(md5(azurerm_resource_group.voting_app.name), 0, 8)}"
}

resource "azurerm_network_interface" "vm" {
  name                = "voting-app-vm-nic"
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.aks.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
}

resource "azurerm_network_interface_security_group_association" "vm" {
  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.voting_app.id
}

resource "azurerm_linux_virtual_machine" "management" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.voting_app.name
  location            = azurerm_resource_group.voting_app.location
  size                = "Standard_B2s"
  admin_username      = local.admin_username
  admin_password      = random_password.admin_password.result
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_container_registry" "voting_app" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.voting_app.name
  location            = azurerm_resource_group.voting_app.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "voting_app" {
  name                = local.cluster_name
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name
  dns_prefix          = local.dns_prefix
  kubernetes_version  = "1.26.3"

  default_node_pool {
    name           = "agentpool"
    node_count     = 3
    vm_size        = "Standard_B2s"
    os_disk_size_gb = 30
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.2.0.0/16"
    dns_service_ip = "10.2.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled = true
  workload_identity_enabled = true

  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = []
  }

  azure_policy_enabled = true

  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.voting_app.id
  }
}

resource "azurerm_role_assignment" "aks_acr" {
  principal_id                     = azurerm_kubernetes_cluster.voting_app.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                           = azurerm_container_registry.voting_app.id
  skip_service_principal_aad_check = true
}

resource "azurerm_log_analytics_workspace" "voting_app" {
  name                = "voting-app-logs"
  location            = azurerm_resource_group.voting_app.location
  resource_group_name = azurerm_resource_group.voting_app.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "voting_app" {
  solution_name         = "ContainerInsights"
  location             = azurerm_resource_group.voting_app.location
  resource_group_name  = azurerm_resource_group.voting_app.name
  workspace_resource_id = azurerm_log_analytics_workspace.voting_app.id
  workspace_name        = azurerm_log_analytics_workspace.voting_app.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.voting_app.name
}

output "acr_name" {
  value = azurerm_container_registry.voting_app.name
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm.fqdn
}

output "admin_username" {
  value = local.admin_username
}

output "admin_password" {
  value     = random_password.admin_password.result
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.voting_app.kube_config_raw
  sensitive = true
}
