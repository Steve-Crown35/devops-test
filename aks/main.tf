resource "azurerm_resource_group" "rg" {
  name     = var.RG_NAME
  location = var.LOCATION
}

module "ServicePrincipal" {
    source = "./modules/ServicePrincipal"
    service_principal_name = var.service_principal_name
    depends_on = [ azurerm_resource_group.rg ]  
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.RG_CLUSTER_NAME
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.RG_CLUSTER_NAME
  automatic_channel_upgrade = var.automatic_channel_upgrade
  sku_tier            = var.sku_tier

  default_node_pool {
    name       = "rchatpool"
    node_count = "1"
    vm_size    = "standard_d2_v2"
    os_sku     = "Ubuntu"
    zones      = [1]
  }
  
  
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    Owner = var.resource_owner
  }

  depends_on = [ azurerm_resource_group.rg, module.ServicePrincipal ]
}