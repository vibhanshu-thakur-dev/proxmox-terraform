output "vm_info" {
  description = "IP address and K3s configuration for each provisioned VM"
  value = [
    for name, vm in proxmox_virtual_environment_vm.vm : {
      name       = vm.name
      ip_address = vm.ipv4_addresses[1][0]
      k3s        = local.vms_map[name].k3s
      user = {
        username = local.vms_map[name].user.username
        ssh_keys = local.vms_map[name].user.ssh_keys
      }
    }
  ]
}
