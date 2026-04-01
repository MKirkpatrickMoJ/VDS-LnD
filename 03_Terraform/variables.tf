variable "rg_name" {
  type        = string
  description = "The resource group for LnD"
}

variable "workspace_name" {
  type        = string
  description = "The name of the Virtual Desktop Workspace"  
}

variable "description" {
  type        = string
  description = "The description of the Virtual Desktop Workspace"  
}

variable "friendly_name" {
  type        = string
  description = "The friendly name of the Virtual Desktop Workspace"
}

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


variable "app_groups" {
  type = map(object({
    name          = string
    type          = string
    host_pool_key = string
  }))
  description = "Maps to application groups and their settings."  
}