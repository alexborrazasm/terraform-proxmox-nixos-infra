terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

# TODO
resource "proxmox_vm_qemu" "vm1" {
  vmid        = 201
  name        = "vm-test-1"
  target_node = "pve"

  clone = "test"

  cpu {
    cores = 2
  }
  memory = 2048

  network {
    id     = local.networks.dmz.id
    model  = "virtio"
    bridge = local.networks.dmz.bridge
  }
}