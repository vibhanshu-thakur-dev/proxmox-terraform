# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
# Initialize Terraform (download providers/modules)
terraform init

# Preview planned changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Format all .tf files
terraform fmt -recursive

# Validate configuration
terraform validate
```

## Authentication Setup

Credentials are passed via `terraform.tfvars` (gitignored). Copy a template or create the file manually:

```hcl
pm_api_url          = "https://<proxmox-host>/api2/json"
pm_api_token_id     = "user@pam!token-name"
pm_api_token_secret = "<secret>"
vms = [...]
```

The provider uses SSH agent (`ssh-agent`) for SSH-based operations — ensure the agent is running and has the appropriate key loaded before running `terraform apply`.

## Architecture

This repo provisions VMs on a Proxmox VE cluster using the **`bpg/proxmox`** provider.

**Two provisioning approaches coexist in `main.tf`:**

1. **Cloud image import** (`proxmox_virtual_environment_download_file` + `proxmox_virtual_environment_vm` with `disk.import_from`): Downloads a cloud image (e.g. CentOS Stream qcow2) directly to a Proxmox node, then creates a VM from it. Used by the `centos_vm` resource.

2. **Clone from template** (not yet implemented as a resource, but `variables.tf` defines a `vms` list with `clone_vm_id`): Intended for cloning from a pre-existing Proxmox VM template (e.g. template ID 9000).

**Key files:**
- [main.tf](main.tf) — provider config and resource definitions
- [variables.tf](variables.tf) — all input variable declarations; `vms` is a list of objects for multi-VM support
- [terraform.tfvars](terraform.tfvars) — actual values (gitignored, must be created locally)

**Provider config** (`provider "proxmox"` in `main.tf`):
- API token auth: `api_token = "${pm_api_token_id}=${pm_api_token_secret}"`
- TLS verification skipped (`insecure = true`) — Proxmox uses self-signed certs
- SSH via agent, username `terraform`

**Proxmox cluster:** targets a multi-node cluster; nodes referenced in resources are `pve-node-1` and `pve-node-2`.
