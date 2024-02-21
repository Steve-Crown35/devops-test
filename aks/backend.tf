#data "terraform_remote_state" "init" {
#  backend = "azurerm"
#  config = {
#    resource_group_name  = "init_rg"
#    storage_account_name = "initinfrasa"
#    container_name       = "tfstate"
#    key                  = "terraform.tfstate"
#  }
#  }
