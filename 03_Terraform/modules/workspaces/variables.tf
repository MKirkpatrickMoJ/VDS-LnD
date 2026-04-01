variable "workspace_name" {
  description = "The name of the Virtual Desktop Workspace"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the workspace"
  type        = string
}

variable "description" {
  description = "The description of the workspace"
  type        = string
}

variable "friendly_name" {
  description = "The friendly name of the workspace"
  type        = string
}
