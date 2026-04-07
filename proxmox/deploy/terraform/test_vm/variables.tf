variable "proxmox_url" {
  type = string
}

variable "api_token" {
  type = string
}

variable "target_node" {
  description = "Proxmox node"
  type        = string
  default     = "pve"
}

variable "vm_configs_dir" {
  description = "Vm Configuration directory"
  type        = string
  default     = "vm_configs"
}

variable "http_server_url" {
  description = "The http server ip"
  type        = string
  default     = "192.168.1.29:8080"
}