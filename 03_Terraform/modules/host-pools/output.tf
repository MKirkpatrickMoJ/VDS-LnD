output "hp-ids" {
  description = "Host pool IDs keyed by host pool map key"
  value = {
    for key, host_pool in azurerm_virtual_desktop_host_pool.host-pools : key => host_pool.id
  }
}