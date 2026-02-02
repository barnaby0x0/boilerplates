locals {
  configs = var.vm_configs
}

output "vm_configs" {
  value = local.configs
}