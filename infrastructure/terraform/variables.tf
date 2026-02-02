variable "pm_api_url" {
  description = "Proxmox API URL (e.g. https://192.168.1.100:8006/api2/json)"
  type        = string
}

variable "pm_user" {
  description = "Proxmox User (e.g. root@pam)"
  type        = string
}

variable "pm_password" {
  description = "Proxmox Password"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Target Proxmox Node Name"
  type        = string
}

variable "template_name" {
  description = "Name of the Cloud-Init Template to clone"
  type        = string
  default     = "ubuntu-cloud"
}

variable "ssh_public_key" {
  description = "SSH Public Key content"
  type        = string
}

variable "gateway" {
  description = "Network Gateway IP"
  type        = string
  default     = "192.168.1.1"
}
