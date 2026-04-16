# terraform-proxmox

Terraform configuration to provision VMs on a Proxmox VE cluster and optionally bootstrap a K3s Kubernetes cluster on them.

## What it does

1. **Provisions VMs on Proxmox** — downloads a cloud image (e.g. CentOS Stream qcow2) to a Proxmox node and creates VMs from it via the `bpg/proxmox` provider.
2. **Installs K3s** — optionally configures the provisioned VMs as K3s server/agent nodes via the `danielbooth-cloud/k3s` provider, including HA multi-server support.

## Requirements

- Terraform >= 1.0
- A running Proxmox VE cluster
- A Proxmox API token with sufficient privileges
- SSH agent running with a key that can reach the provisioned VMs (`ssh-agent`)
- QEMU Guest Agent enabled in your cloud image (required for IP address detection)

## Project structure

```
.
├── main.tf              # Root module — wires proxmox and k3s modules together
├── providers.tf         # Provider declarations and configuration
├── variables.tf         # Root input variable declarations
├── terraform.tfvars     # Your credentials and VM definitions (gitignored)
└── modules/
    ├── proxmox/         # Downloads cloud images and creates VMs
    └── k3s/             # Bootstraps K3s server/agent nodes over SSH
```

## Quick start

1. **Copy and fill in credentials:**

   ```hcl
   # terraform.tfvars
   pm_api_url          = "https://<proxmox-host>:8006/api2/json"
   pm_api_token_id     = "user@pam!token-name"
   pm_api_token_secret = "<secret>"
   ssh_private_key     = <<EOT
   -----BEGIN OPENSSH PRIVATE KEY-----
   ...
   -----END OPENSSH PRIVATE KEY-----
   EOT

   vms = [
     {
       name      = "k3s-server-1"
       node_name = "pve-node-1"
       os = {
         image_url    = "https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
         datastore_id = "local"
       }
       cores  = 2
       memory = 4096
       disk = {
         datastore_id = "local-lvm"
         size         = 32
       }
       network_device = {
         bridge = "vmbr0"
       }
       user = {
         username = "centos"
         ssh_keys = ["ssh-ed25519 AAAA..."]
       }
       k3s = {
         enabled = true
         mode    = "server"
       }
     }
   ]
   ```

2. **Start your SSH agent:**

   ```bash
   eval $(ssh-agent)
   ssh-add ~/.ssh/your_key
   ```

3. **Initialize and apply:**

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Retrieve the kubeconfig** (if K3s was provisioned):

   ```bash
   terraform output -raw kubeconfig > ~/.kube/config
   ```

## Input variables

| Variable | Description | Default |
|---|---|---|
| `pm_api_url` | Proxmox API endpoint URL | required |
| `pm_api_token_id` | API token ID (`user@pam!token-name`) | required |
| `pm_api_token_secret` | API token secret | required |
| `pm_tls_insecure` | Skip TLS verification (Proxmox uses self-signed certs) | `true` |
| `ssh_private_key` | PEM-encoded private key for SSH access to VMs | required |
| `vms` | List of VM definitions (see below) | required |

### VM object schema

| Field | Description | Default |
|---|---|---|
| `name` | VM name | required |
| `node_name` | Proxmox node to place the VM on | required |
| `stop_on_destroy` | Stop VM before destroying | `true` |
| `os.image_url` | Cloud image URL to download | required |
| `os.datastore_id` | Proxmox datastore for the image | `"local"` |
| `cores` | vCPU cores | required |
| `sockets` | vCPU sockets | `1` |
| `memory` | RAM in MB | required |
| `disk.datastore_id` | Datastore for the VM disk | required |
| `disk.interface` | Disk interface | `"virtio0"` |
| `disk.size` | Disk size in GB | required |
| `disk.discard` | Discard/TRIM setting | `"on"` |
| `disk.iothread` | Enable I/O thread | `true` |
| `network_device.bridge` | Network bridge | required |
| `network_device.model` | NIC model | `"virtio"` |
| `user.username` | Cloud-init username | required |
| `user.password` | Cloud-init password | `null` |
| `user.ssh_keys` | List of authorized SSH public keys | `[]` |
| `k3s.enabled` | Install K3s on this VM | optional |
| `k3s.mode` | `"server"` or `"agent"` | optional |

## K3s topology

- The **first** VM with `k3s.mode = "server"` bootstraps the cluster (`cluster_init = true`).
- Additional server VMs join as HA control-plane nodes.
- VMs with `k3s.mode = "agent"` join as worker nodes.
- All K3s nodes depend on the proxmox module completing first.

## Outputs

| Output | Description |
|---|---|
| `kubeconfig` | Kubeconfig for the K3s cluster (sensitive) |

## Notes

- `terraform.tfvars`, state files, and `.terraform/` are gitignored — never commit credentials or state.
- The same cloud image URL on different Proxmox nodes triggers a separate download per node.
- VMs use DHCP; the QEMU Guest Agent reports the assigned IP back to Terraform.
