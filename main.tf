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

  vm_info          = module.proxmox.vm_info
  ssh_private_key  = var.ssh_private_key
  k3s_api_hostname = var.k3s_api_hostname

  depends_on = [module.proxmox]
}

# Write kubeconfig to disk so the helm provider (configured in providers.tf)
# can read it. The path is static; the content is written during apply after k3s bootstraps.
resource "local_sensitive_file" "kubeconfig" {
  content         = module.k3s.kubeconfig
  filename        = "${path.root}/k3s.kubeconfig"
  file_permission = "0600"

  depends_on = [module.k3s]
}

module "helm" {
  source = "./modules/helm"

  releases   = var.helm_releases
  values_dir = "${path.root}/helm-values"

  depends_on = [local_sensitive_file.kubeconfig, module.k3s]
}
