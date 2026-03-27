output "id" {
  description = "ID of the host pool"
  value       = azurerm_virtual_desktop_host_pool.host-pools[*].id
}