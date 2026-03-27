variable "host_pools" {
  type = map(object({
    name                = string
    friendly_name       = string
    resource_group_name = string
    location            = string
    type                = string
    load_balancer_type  = string
    description         = string
  }))
  description = "Maps to host pools and their settings."
}