resource "random_integer" "uuid" {
  min = 100
  max = 999
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.aks_rg_name}-${terraform.workspace}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}-${terraform.workspace}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space       = var.vnet_address_space

  tags = {
    environment = "dev"
  }
}

resource "azurerm_public_ip" "ingress_ip" {
  name                = "${azurerm_resource_group.resource_group.name}${random_integer.uuid.result}pip"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group

  allocation_method = "Static"
  domain_name_label = "${azurerm_resource_group.resource_group.name}-istio"

  tags = {
    environment = "istio"
  }
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.aks_subnet_name}-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefix       = var.aks_subnet_address
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "vk_subnet" {
  name                 = "${var.vk_subnet_name}-${terraform.workspace}"
  resource_group_name  = azurerm_resource_group.resource_group.name
  address_prefix       = var.vk_subnet_address
  virtual_network_name = azurerm_virtual_network.vnet.name

  delegation {
    name = "aciDelegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.cluster_name}-${terraform.workspace}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  agent_pool_profile {
    name            = "default"
    count           = var.node_count
    vm_size         = var.vm_size
    os_type         = "Linux"
    os_disk_size_gb = 30
    max_pods        = var.max_pods
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    type            = "VirtualMachineScaleSets"
  }

  linux_profile {
    admin_username = "k8sadmin"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  network_profile {
    network_plugin = "azure"
  }

  service_principal {
    client_id     = data.azurerm_client_config.current.client_id
    client_secret = var.client_secret
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    aci_connector_linux {
      enabled     = true
      subnet_name = azurerm_subnet.vk_subnet.name
    }
  }

  tags = {
    environment = "istio"
  }
}

/*resource "azurerm_dns_zone" "dns_zone" {
  name                = var.zone_name
  resource_group_name = azurerm_resource_group.resource_group.name
  zone_type           = "Public"
}

resource "azurerm_dns_a_record" "jenkins" {
  name                = "jenkins"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_ip.ip_address]
}

resource "azurerm_dns_a_record" "spinnaker_ingress" {
  name                = "spinnaker"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_ip.ip_address]
}

resource "azurerm_dns_a_record" "spinnaker_ingress_gate" {
  name                = "gate.spinnaker"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_ip.ip_address]
}

resource "azurerm_dns_a_record" "hipster" {
  name                = "hipster"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300
  records             = [azurerm_public_ip.ingress_ip.ip_address]
}*/