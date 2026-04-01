### Terraform variables for development environment
### Resource Group Module Vars:
rg_name = "rg-dev-lnd-MKTest-001"

################################################
######## TASK 2 ################################
################################################
### Workspace Module Vars:
workspace_name = "ws-dev-lnd-MKTest-001"
description    = "Development Virtual Desktop Workspace"
friendly_name  = "Dev Workspace"

################################################
######## TASK 3 ################################
################################################
### Host Pool Module Vars:
host_pools = {
  HP_Pooled = {
    name               = "HP-Pooled-DEV"
    friendly_name      = "Pooled Host Pool"
    type               = "Pooled"
    load_balancer_type = "BreadthFirst"
    description        = "Pooled host pool for development environment"
  }
  HP_Personal = {
    name               = "HP-Personal-DEV"
    friendly_name      = "Personal Host Pool"
    type               = "Personal"
    load_balancer_type = "Persistent"
    description        = "Personal host pool for development environment"
  }
}

################################################
######## TASK 4 ################################
################################################
### App Group Module Vars:
app_groups = {
 AG_RemoteApp = {
    name          = "AG-RemoteApp"
    type          = "RemoteApp"
    host_pool_key = "HP_Pooled"
  }
 AG_Desktop = {
    name          = "AG-Desktop"
    type          = "Desktop"
    host_pool_key = "HP_Personal"
 }
}