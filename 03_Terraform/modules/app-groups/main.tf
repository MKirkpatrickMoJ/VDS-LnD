resource "azurerm_virtual_desktop_application_group" "app-groups" {
  name                = var.app_group_name
  resource_group_name = var.resource_group_name
  location            = var.location
  host_pool_id        = var.host_pool_id
  type                = var.app_group_type
}