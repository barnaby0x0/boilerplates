locals {
  ct_configs = flatten([
    for file in fileset(var.ct_configs_dir, "*.yaml") : [
      yamldecode(templatefile("${var.ct_configs_dir}/${file}", {
        vpn_privatekey     = var.vpn_private_key
        vpn_publickey      = var.vpn_public_key
        vps_wg_public_ip   = var.vps_wg_public_ip
        vps_wg_public_port = var.vps_wg_public_port
      }))
      # yamldecode(file("${var.ct_configs_dir}/${file}"))
    ]
  ])
}

module "config" {
  source     = "../modules/definitions"
  ct_configs = local.ct_configs
}

# output "expanded_ct_configs" {
#   value = module.config.expanded_ct_configs
# }

locals {
  configs = module.config.ct_configs
}
