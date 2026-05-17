output "git_repository_name" {
  value = kubectl_manifest.git_repository.name
}

output "kustomization_name" {
  value = kubectl_manifest.kustomization.name
}
