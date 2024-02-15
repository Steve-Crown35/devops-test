# create the init resource group for managing backend resources
resource "azurerm_resource_group" "init_rg" {
  name     = var.rg
  location = var.location
}

# create the storage account for terraform's remote backend
resource "azurerm_storage_account" "init_sa" {
  name                     = var.init_infra_sa
  resource_group_name      = azurerm_resource_group.init_rg.name
  location                 = azurerm_resource_group.init_rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  depends_on = [ azurerm_resource_group.init_rg ]
}

# create blob container for terraform backend
resource "azurerm_storage_container" "init_sac" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.init_sa.name
  container_access_type = var.container_access_type

  depends_on = [ azurerm_resource_group.init_rg, azurerm_storage_account.init_sa ]
}

# create keyvault to store secrets
resource "azurerm_key_vault" "init_kv" {
  name                        = var.init_keyvault
  location                    = azurerm_resource_group.init_rg.location
  resource_group_name         = azurerm_resource_group.init_rg.name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption 
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled

  sku_name = var.sku_name

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }

  depends_on = [ azurerm_resource_group.init_rg, azurerm_storage_account.init_sa, azurerm_storage_container.init_sac ]
}