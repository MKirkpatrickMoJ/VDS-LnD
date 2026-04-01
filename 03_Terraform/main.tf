module "resource-groups" {
  source  = "./modules/resource-groups"
  rg_name = var.rg_name
}

module "workspaces" {
  depends_on = [ module.resource-groups ]

  source              = "./modules/workspaces"
  workspace_name      = var.workspace_name
  resource_group_name = module.resource-groups.name
  location            = module.resource-groups.location
  description         = var.description
  friendly_name       = var.friendly_name
}

module "host-pools" {
  depends_on = [ module.workspaces ]

  source              = "./modules/host-pools"
  host_pools          = var.host_pools
  resource_group_name = module.resource-groups.name
  location            = module.resource-groups.location
}

module "app-groups" {
  for_each = var.app_groups

  source              = "./modules/app-groups"
  app_group_name      = each.value.name
  app_group_type      = each.value.type
  host_pool_id        = module.host-pools.hp-ids[each.value.host_pool_key]
  resource_group_name = module.resource-groups.name
  location            = module.resource-groups.location
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "association" {
  for_each = var.app_groups

  workspace_id              = module.workspaces.id
  application_group_id      = module.app-groups[each.key].app_group_id
}