terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

resource "kubernetes_secret" "github_auth" {
  metadata {
    name      = "flux-github-auth"
    namespace = "flux-system"
  }

  data = {
    username = "git"
    password = var.github_token
  }
}

resource "kubectl_manifest" "git_repository" {
  yaml_body = yamlencode({
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"
    metadata = {
      name      = "flux-system"
      namespace = "flux-system"
    }
    spec = {
      interval = "1m0s"
      ref = {
        branch = var.git_branch
      }
      url = var.git_repository_url
      secretRef = {
        name = kubernetes_secret.github_auth.metadata[0].name
      }
    }
  })

  depends_on = [kubernetes_secret.github_auth]
}

resource "kubectl_manifest" "kustomization" {
  yaml_body = yamlencode({
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind       = "Kustomization"
    metadata = {
      name      = "flux-system"
      namespace = "flux-system"
    }
    spec = {
      interval = "10m0s"
      path     = var.git_path
      prune    = true
      sourceRef = {
        kind = "GitRepository"
        name = "flux-system"
      }
    }
  })

  depends_on = [kubectl_manifest.git_repository]
}
