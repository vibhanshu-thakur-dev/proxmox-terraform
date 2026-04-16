output "kubeconfig" {
  description = "Kubeconfig for the provisioned K3s cluster"
  value       = k3s_server.bootstrap.kubeconfig
  sensitive   = true
}
