module "proxmox" {
  source = "./modules/proxmox"

  vms                 = var.vms
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

module "k3s" {
  source = "./modules/k3s"

  vm_info         = module.proxmox.vm_info
  ssh_private_key = var.ssh_private_key

  depends_on = [module.proxmox]
}
