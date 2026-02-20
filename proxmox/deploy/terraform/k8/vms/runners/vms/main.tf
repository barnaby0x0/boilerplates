# locals {
#   vm_configs = flatten([
#     for file in fileset(var.vm_configs_dir, "*.yaml") : [
#       base64encode(
#         yamldecode(templatefile("${var.vm_configs_dir}/${file}", {
#           http_server_url = var.http_server_url
#         }))
#       )
#     ]
#   ])
# }

locals {
  vm_configs = flatten([
    for file in fileset(var.vm_configs_dir, "*.yaml") : [
      base64encode(templatefile("${var.vm_configs_dir}/${file}", {
        http_server_url = var.http_server_url
      }))
    ]
  ])
}

module "vms" {
  source = "../../../../modules/vms"
  proxmox_connection = var.proxmox_connection
  vm_definitions = local.vm_configs
  target_node = "k8"
}

# output "name" {
#   value = module.vms.name
# }