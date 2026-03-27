resource "azurerm_virtual_desktop_host_pool" "host-pools" {
  for_each = var.host_pools

  name                = each.value.name
  friendly_name       = each.value.friendly_name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  type                = each.value.type
  load_balancer_type  = each.value.load_balancer_type
  description         = each.value.description
  start_vm_on_connect = true
}