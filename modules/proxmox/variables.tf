variable "pm_api_url" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Skip TLS verification for the Proxmox API"
  type        = bool
  default     = true
}

variable "vms" {
  description = "List of VMs to provision"
  type = list(object({
    name            = string
    node_name       = string
    stop_on_destroy = optional(bool, true)

    os = object({
      image_url    = string
      datastore_id = optional(string, "local")
    })

    cores   = number
    sockets = optional(number, 1)
    memory  = number

    disk = object({
      datastore_id = string
      interface    = optional(string, "virtio0")
      size         = number
      discard      = optional(string, "on")
      iothread     = optional(bool, true)
    })

    network_device = object({
      model  = optional(string, "virtio")
      bridge = string
    })

    user = object({
      username = string
      password = optional(string, null)
      ssh_keys = optional(list(string), [])
    })

    k3s = optional(object({
      enabled = bool
      mode    = string
    }), null)
  }))
}
