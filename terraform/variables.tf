variable "azure_subscription_id" {
  type    = string
  default = "00000000-0000-0000-0000-000000000000"
}

variable "rg_name" {
  type    = string
  default = "cdn"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1ls"
}

// can be one of [Premium_LRS, Standard_LRS, StandardSSD_LRS]
variable "vm_disk_type" {
  type    = string
  default = "Standard_LRS"
}

variable "username" {
  type    = string
  default = "chef"
}

variable "unique_id" {
  type    = string
  default = "galenguyer"
}

variable "node_count" {
  type    = number
  default = 3
}

variable "node_locations" {
  type    = list(string)
  default = ["canadacentral", "westus2", "uksouth", "southeastasia", "brazilsouth", "uaenorth"]
}
