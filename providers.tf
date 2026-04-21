terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.97"
    }
    k3s = {
      source  = "danielbooth-cloud/k3s"
      version = "~> 0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pm_api_url
  api_token = "${var.pm_api_token_id}=${var.pm_api_token_secret}"
  insecure  = var.pm_tls_insecure
  ssh {
    agent    = true
    username = "terraform"
  }
}

provider "k3s" {}

# kubeconfig is written to disk by main.tf after k3s bootstraps.
# The path is a static string (known at plan time); the provider reads the
# file at connection time during apply, after the file has been written.
provider "helm" {
  kubernetes {
    config_path = "${path.root}/k3s.kubeconfig"
  }
}
