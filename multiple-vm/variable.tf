variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_target_node" {
  type    = string
  default = "pve-node-1"
}

variable "proxmox_vm_template" {
  type    = string
  default = "ubuntu-jammy"
}

variable "vm_name" {
  type    = string
  default = "vm-demo"
}

variable "vm_user" {
  type = string
}

variable "vm_pass" {
  type      = string
  sensitive = true
}

variable "vm_count" {
  type    = number
  default = 3
}
