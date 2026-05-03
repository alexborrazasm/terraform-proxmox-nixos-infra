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
  pm_timeout          = 1800
}

locals {
  vms = {
    caddy = {
      vmid   = 110
      ip     = "10.60.60.10"
      cores  = 6
      memory = 2048
      tags   = "nixos;dmz"
    }
    worker1 = {
      vmid   = 111
      ip     = "10.60.60.11"
      cores  = 1
      memory = 2048
      tags   = "nixos;dmz;worker;nginx"
    }
    worker2 = {
      vmid   = 112
      ip     = "10.60.60.12"
      cores  = 1
      memory = 2048
      tags   = "nixos;dmz;worker;nginx"
    }
    worker3 = {
      vmid   = 113
      ip     = "10.60.60.13"
      cores  = 1
      memory = 2048
      tags   = "nixos;dmz;worker;nginx"
    }
    monitoring = {
      vmid   = 114
      ip     = "10.60.60.14"
      cores  = 2
      memory = 4096
      tags   = "nixos;monitoring;grafana;prometheus"
    }
  }
}

resource "proxmox_vm_qemu" "vms" {
  for_each = local.vms

  vmid        = each.value.vmid
  name        = "nixos-${each.key}"
  target_node = "pve"
  clone       = "debian-12-template"
  full_clone  = true
  tags        = each.value.tags

  agent    = 1
  os_type  = "l26"
  scsihw   = "virtio-scsi-single"
  vm_state = var.vm_state
  onboot   = true
  boot     = "order=scsi0"

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  memory = each.value.memory

  disks {
    scsi {
      scsi0 {
        disk {
          storage  = "local-lvm"
          size     = "20G"
          iothread = true
        }
      }
      scsi1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr2"
  }

  ipconfig0  = "ip=${each.value.ip}/24,gw=10.60.60.1"
  nameserver = "10.60.60.1"
  sshkeys    = var.sshkeys
  cipassword = var.cipassword

  ciupgrade = false

  timeouts {
    create = "40m"
  }
}
