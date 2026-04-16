terraform {
  required_providers {
    k3s = {
      source  = "danielbooth-cloud/k3s"
      version = "~> 0.2"
    }
  }
}

locals {
  # All VMs where K3s is enabled
  k3s_vms = [for vm in var.vm_info : vm if try(vm.k3s.enabled, false)]

  servers       = [for vm in local.k3s_vms : vm if vm.k3s.mode == "server"]
  agents        = [for vm in local.k3s_vms : vm if vm.k3s.mode == "agent"]
  bootstrap     = local.servers[0]
  extra_servers = slice(local.servers, 1, length(local.servers))
}

# First server: bootstraps the cluster.
# highly_available.cluster_init designates this node as the HA init node;
# it is safe to set even for single-server deployments.
resource "k3s_server" "bootstrap" {
  auth = {
    host        = local.bootstrap.ip_address
    user        = local.bootstrap.user.username
    private_key = var.ssh_private_key
  }

  highly_available = {
    cluster_init = true
  }
}

# Additional server nodes join the bootstrap server (HA control-plane)
resource "k3s_server" "additional" {
  for_each = { for s in local.extra_servers : s.name => s }

  auth = {
    host        = each.value.ip_address
    user        = each.value.user.username
    private_key = var.ssh_private_key
  }

  highly_available = {
    server = k3s_server.bootstrap.server
    token  = k3s_server.bootstrap.token
  }

  depends_on = [k3s_server.bootstrap]
}

# Agent (worker) nodes join the cluster
resource "k3s_agent" "agents" {
  for_each = { for a in local.agents : a.name => a }

  auth = {
    host        = each.value.ip_address
    user        = each.value.user.username
    private_key = var.ssh_private_key
  }

  kubeconfig = k3s_server.bootstrap.kubeconfig
  server     = k3s_server.bootstrap.server
  token      = k3s_server.bootstrap.token

  depends_on = [k3s_server.bootstrap]
}
