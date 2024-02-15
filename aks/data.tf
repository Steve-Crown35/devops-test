data "azurerm_resource_group" "init_rg_data" {
  name = "init_rg"
}

data "azurerm_storage_account" "init_sa_data" {
  name                = "initinfrasa"
  resource_group_name = "init_rg"
}

data "azurerm_storage_container" "init_sac_data" {
  name                = "tfstate"
  storage_account_name = "initinfrasa"
}



