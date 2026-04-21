output "release_names" {
  description = "Names of deployed Helm releases"
  value       = [for r in helm_release.charts : r.name]
}
