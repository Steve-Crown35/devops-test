variable "RG_NAME" {
    type = string
    description = "name of the resource group to deploy resources"
    default = "aks-resource-group"
}

variable "RG_CLUSTER_NAME" {
    type = string
    description = "name of the azure kubernetes cluster"  
}

variable "LOCATION" {
    type = string
    description = "name of azure location where resources are deployed"
    default = "westeurope"
}

variable "resource_owner" {
    type = string
    description = "name of the resource owner"
    default = "Stephen Okon"
}
variable "service_principal_name" {
    type = string
    description = "name of the service principal"
    default = "aks-cluster-spn"
}

variable "SUBSCRIPTION_ID" {
    type = string
    description = "azure subscription id"
    default = "3b95c837-890a-4f1a-9488-ca9b0dc28d46"
}

variable "environment" {
    type = string
    description = "name of environment where resource is deployed"
}

variable "tfstatekey" {
    type = string
    description = "name of the terraform state key"
    default = "terraform.tfstate"
}

variable "automatic_channel_upgrade" {
    type = string
    description = "The upgrade channel for Kubernetes Cluster. Possible values are patch, rapid, node-image and stable."
    default = "patch"
}

variable "sku_tier" {
    type = string
    description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, Standard (which includes the Uptime SLA) and Premium."
    default = "Free"
}







