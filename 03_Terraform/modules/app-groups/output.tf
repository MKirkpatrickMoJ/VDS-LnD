output "app_group_id" {
  value       = azurerm_virtual_desktop_application_group.app-groups.id
  description = "ID of the application group"
}