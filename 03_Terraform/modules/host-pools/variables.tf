variable "host_pools" {
  type = map(object({
    name               = string
    friendly_name      = string
    type               = string
    load_balancer_type = string
    description        = string
  }))
  description = "Maps to host pools and their settings."
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where host pools will be created."
}
variable "location" {
  type        = string
  description = "Location where the host pools will be created."
}