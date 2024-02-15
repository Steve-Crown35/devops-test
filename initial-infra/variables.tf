variable "rg" {
    type = string
    description = "name of the resource group"
    default = "init_rg"  
}

variable "location" {
    type = string
    description = "location of the resource group"
    default = "westeurope"  
}

variable "init_infra_sa" {
    type = string
    description = "name of init storage account"
    default = "initinfrasa"  
}

variable "account_tier" {
    type = string
    description = "storage account tier"
    default = "Standard"  
}

variable "account_replication_type" {
    type = string
    description = "storage account replication type"
    default = "GRS"  
}

variable "init_keyvault" {
    type = string
    description = "name of key vault"
    default = "initinfrakv"  
}

variable "enabled_for_disk_encryption" {
    type = bool
    description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
    default = true  
}

variable "soft_delete_retention_days" {
    type = number
    description = "The number of days that items should be retained for once soft-deleted"
    default = 7  
}

variable "purge_protection_enabled" {
    type = bool
    description = "Boolean flag to specify whether Purge Protection is enabled for Key Vault"
    default = false 
}

variable "sku_name" {
    type = string
    description = "The Name of the SKU used for the Key Vault. Possible values are standard and premium."
    default = "standard"
}

variable "storage_container_name" {
    type = string
    description = "The Name of the storage container"
    default = "tfstate"
}

variable "container_access_type" {
    type = string
    description = "The Access Level configured for this Container. Possible values are blob, container or private."
    default = "container"
}





