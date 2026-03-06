variable "proxmox_url" { type = string }
variable "api_token" { type = string }

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
  default     = "192.168.1.31:8080"
}

variable "gitlab_runner_token_nixos" {
  type    = string
  default = ""
}

variable "gitlab_runner_token_ubuntu" {
  type    = string
  default = ""
}

variable "test" {
  type    = string
  default = <<-EOT
{
  "insecure-registries": [
    "10.0.0.250:5000"
  ],
  "registry-mirrors": ["http://10.0.0.250:5001"]
}
EOT
}