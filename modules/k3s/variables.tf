variable "vm_info" {
  description = "List of provisioned VM details output by the proxmox module"
  type = list(object({
    name       = string
    ip_address = string
    user = object({
      username = string
      ssh_keys = optional(list(string), [])
    })
    k3s = optional(object({
      enabled = bool
      mode    = string
    }), null)
  }))
}

variable "ssh_private_key" {
  description = "PEM-encoded private key used to SSH into VMs for K3s installation"
  type        = string
  sensitive   = true
}
