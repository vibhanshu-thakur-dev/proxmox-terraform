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
