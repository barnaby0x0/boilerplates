locals {
  vm_configs = flatten([
    for file in fileset(var.vm_configs_dir, "*.yaml") : [
      yamldecode(templatefile("${var.vm_configs_dir}/${file}", {
        http_server_url = var.http_server_url
        secret1         = base64encode(var.test)
      }))
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
