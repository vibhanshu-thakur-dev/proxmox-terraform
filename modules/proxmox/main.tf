terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.97"
    }
  }
}

locals {
  vms_map = { for vm in var.vms : vm.name => vm }

  # Key images by "url::node_name" so the same image used on different nodes
  # gets a separate entry. The ... grouping operator collapses duplicate keys
  # into lists; we take the first entry.
  image_keys = {
    for key, vals in {
      for vm in var.vms :
      "${vm.os.image_url}::${vm.node_name}" => {
        url          = vm.os.image_url
        node_name    = vm.node_name
        datastore_id = vm.os.datastore_id
      }...
    } :
    key => vals[0]
  }
}

resource "proxmox_virtual_environment_download_file" "image" {
  for_each = local.image_keys

  node_name    = each.value.node_name
  datastore_id = each.value.datastore_id
  url          = each.value.url
  content_type = "import"
  file_name    = "${trimsuffix(trimsuffix(regex("[^/]+$", each.value.url), ".img"), ".qcow2")}.qcow2"
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = local.vms_map

  name            = each.value.name
  node_name       = each.value.node_name
  stop_on_destroy = each.value.stop_on_destroy

  cpu {
    cores   = each.value.cores
    sockets = each.value.sockets
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = each.value.disk.datastore_id
    import_from  = proxmox_virtual_environment_download_file.image["${each.value.os.image_url}::${each.value.node_name}"].id
    interface    = each.value.disk.interface
    size         = each.value.disk.size
    discard      = each.value.disk.discard
    iothread     = each.value.disk.iothread
  }

  network_device {
    model  = each.value.network_device.model
    bridge = each.value.network_device.bridge
  }

  agent {
    enabled = true
    wait_for_ip {
      ipv4 = true
    }
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = each.value.user.username
      password = each.value.user.password
      keys     = each.value.user.ssh_keys
    }
  }
}
