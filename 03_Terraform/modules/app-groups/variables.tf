variable "app_group_name" {
  type        = string
  description = "Name of the application group."
}
variable "app_group_type" {
  type        = string
  description = "Type of the application group. Allowed values are 'RemoteApp' and 'Desktop'."
}
variable "location" {
  type        = string
  description = "Location where the application group will be created."
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where the application group will be created."
}
variable "host_pool_id" {
  type = string
  description = "ID of the host pool to which the application group will be associated."
}