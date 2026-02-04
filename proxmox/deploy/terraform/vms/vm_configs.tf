locals {
  vm_configs = flatten([
    for file in fileset(var.vm_configs_dir, "*.yaml") : [
      yamldecode(file("${var.vm_configs_dir}/${file}"))
    ]
  ])
}

module "config" {
  source     = "../modules/definitions"
  vm_configs = local.vm_configs
}

locals {
  configs = module.config.vm_configs
}
