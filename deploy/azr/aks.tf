resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [azurerm_subnet.aks_subnet]
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
  network_plugin     = "azure"
  load_balancer_sku  = "standard"
  network_policy     = "azure"
  dns_service_ip     = "10.2.0.10"
  service_cidr       = "10.2.0.0/24"
  outbound_type      = "loadBalancer"
}


  role_based_access_control_enabled = true
}
