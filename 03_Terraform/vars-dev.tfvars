### Terraform variables for development environment
### Resource Group Module Vars:
rg_name = "rg-dev-lnd-[NAME]-001"

################################################
######## TASK 2 ################################
################################################
### Workspace Module Vars:


################################################
######## TASK 3 ################################
################################################
### Host Pool Module Vars:
# host_pools = {
#   HP_Pooled = {
#     name               = "HP-Pooled"
#     load_balancer_type = "BreadthFirst"
#   }
#   HP_Personal = {}
# }

################################################
######## TASK 4 ################################
################################################
### App Group Module Vars:
# app_groups = {
#  AG_RemoteApp = {
#     name          = "AG-RemoteApp"
#     type          = "RemoteApp"
#     host_pool_key = "HP_Pooled"
#   }
#  AG_Desktop = {
#    VALUES NEEDED
#  }
# }