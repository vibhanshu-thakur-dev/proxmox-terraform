variable "github_token" {
  description = "GitHub personal access token (needs repo read scope)"
  type        = string
  sensitive   = true
}

variable "git_repository_url" {
  description = "HTTPS URL of the GitOps repo (e.g. https://github.com/org/repo)"
  type        = string
}

variable "git_branch" {
  description = "Branch Flux should watch"
  type        = string
  default     = "main"
}

variable "git_path" {
  description = "Path inside the repo containing Flux Kustomization manifests"
  type        = string
  default     = "./clusters/home"
}
