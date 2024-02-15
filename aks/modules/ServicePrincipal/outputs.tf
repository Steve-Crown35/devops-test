output "service_principal_name" {
    description = "The name of the service principal. It can be used to assign roles to the service principal."
    value = azuread_service_principal.spn.display_name  
}

output "service_principal_object_id" {
    description = "The object id of the service principal. It can be used to assign roles to the service principal."
    value = azuread_service_principal.spn.object_id
  
}

output "service_principal_tenant_id" {
    description = "The tenant id of the service principal."
    value = azuread_service_principal.spn.application_tenant_id
}

output "service_principal_application_id" {
    description = "The application id of the service principal."
    value = azuread_service_principal.spn.application_id
}

output "client_id" {
    description = "The tenant id of the service principal."
    value = azuread_service_principal.spn.client_id  
}

output "client_secret" {
    
    description = "The tenant id of the service principal."
    value = azuread_service_principal_password.spn_password 
}