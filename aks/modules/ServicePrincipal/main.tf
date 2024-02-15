data "azuread_client_config" "current" {}

resource "azuread_application" "spn_app" {
  display_name = var.service_principal_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "spn" {
  client_id                    = azuread_application.spn_app.client_id
  app_role_assignment_required = true
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "time_rotating" "rotate_password" {
  rotation_days = 90
}

resource "azuread_service_principal_password" "spn_password" {
  service_principal_id = azuread_service_principal.spn.object_id
  rotate_when_changed = {
    rotation = time_rotating.rotate_password.id
  }
}