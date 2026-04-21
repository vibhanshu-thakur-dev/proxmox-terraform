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

variable "k3s_api_hostname" {
  description = "DNS hostname for the K3s API server (added as TLS SAN; kubeconfig will use this instead of the bootstrap node IP)"
  type        = string
  default     = null
}
