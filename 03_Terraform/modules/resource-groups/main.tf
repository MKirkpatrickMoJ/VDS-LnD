resource "azurerm_resource_group" "LnD_RG" {
  name     = var.rg_name
  location = var.location
}