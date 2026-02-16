locals {
  ct_configs = flatten([
    for file in fileset(var.ct_configs_dir, "*.yaml") : [
      yamldecode(file("${var.ct_configs_dir}/${file}"))
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
