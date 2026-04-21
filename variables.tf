variable "pm_api_url" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID (e.g. user@pam!token-name)"
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

variable "ssh_private_key" {
  description = "PEM-encoded private key used by the K3s provider to SSH into provisioned VMs"
  type        = string
  sensitive   = true
}

variable "k3s_api_hostname" {
  description = "DNS hostname for the K3s API (e.g. k3s.example.com). Must resolve to a control-plane node or load-balancer VIP. Will be added as a TLS SAN and used in the kubeconfig."
  type        = string
  default     = null
}

variable "helm_releases" {
  description = "Helm charts to install onto the K3s cluster after provisioning. Values are loaded from helm-values/<name>.yaml if the file exists."
  type = list(object({
    name             = string
    chart            = string
    repository       = string
    namespace        = optional(string, "default")
    version          = optional(string, null)
    create_namespace = optional(bool, true)
  }))
  default = []
}

variable "vms" {
  description = "Master list of VMs to provision in Proxmox and optionally configure with K3s"
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
      mode    = string # "server" or "agent"
    }), null)
  }))
}
