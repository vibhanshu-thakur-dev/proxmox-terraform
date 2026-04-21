output "kubeconfig" {
  description = "Kubeconfig for the provisioned K3s cluster"
  value = var.k3s_api_hostname != null ? replace(
    k3s_server.bootstrap.kubeconfig,
    "https://${local.bootstrap.ip_address}:6443",
    "https://${var.k3s_api_hostname}:6443"
  ) : k3s_server.bootstrap.kubeconfig
  sensitive = true
}
