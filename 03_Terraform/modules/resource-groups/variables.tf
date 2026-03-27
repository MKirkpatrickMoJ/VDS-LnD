variable "location" {
  type        = string
  description = "Azure region for the resource group"
  default     = "uksouth"
}
variable "rg_name" {
  type        = string
  description = "Name for the resource group"
}