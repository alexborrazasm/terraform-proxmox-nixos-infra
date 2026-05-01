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

resource "proxmox_vm_qemu" "vm1" {
  vmid        = 110
  name        = "nixos-caddy"
  target_node = "pve"
  clone       = "debian-12-template"
  full_clone  = true
  tags        = "nixos;dmz"

  agent    = 1
  os_type  = "l26"
  scsihw   = "virtio-scsi-single"
  vm_state = var.vm_state
  onboot   = true
  boot     = "order=virtio0"

  cpu {
    cores   = 6
    sockets = 1
    type    = "host"
  }

  memory = 2048

  disks {
    virtio {
      virtio0 {
        disk {
          storage  = "local-lvm"
          size     = "20G"
          iothread = true
        }
      }
    }
    scsi {
      scsi0 {
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

  # Cloud-init
  ipconfig0  = "ip=10.60.60.10/24,gw=10.60.60.1"
  nameserver = "10.60.60.1"
  sshkeys    = var.sshkeys
  cipassword = var.cipassword

  ciupgrade = false
}

resource "proxmox_vm_qemu" "vm2" {
  vmid        = 111
  name        = "nixos-worker1"
  target_node = "pve"
  clone       = "debian-12-template"
  full_clone  = true
  tags        = "nixos;dmz;worker;nginx"

  agent    = 1
  os_type  = "l26"
  scsihw   = "virtio-scsi-single"
  vm_state = var.vm_state
  onboot   = true
  boot     = "order=virtio0"

  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  memory = 2048

  disks {
    virtio {
      virtio0 {
        disk {
          storage  = "local-lvm"
          size     = "20G"
          iothread = true
        }
      }
    }
    scsi {
      scsi0 {
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

  # Cloud-init
  ipconfig0  = "ip=10.60.60.11/24,gw=10.60.60.1"
  nameserver = "10.60.60.1"
  sshkeys    = var.sshkeys
  cipassword = var.cipassword

  ciupgrade = false
}

resource "proxmox_vm_qemu" "vm3" {
  vmid        = 112
  name        = "nixos-worker2"
  target_node = "pve"
  clone       = "debian-12-template"
  full_clone  = true
  tags        = "nixos;dmz;worker;nginx"

  agent    = 1
  os_type  = "l26"
  scsihw   = "virtio-scsi-single"
  vm_state = var.vm_state
  onboot   = true
  boot     = "order=virtio0"

  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  memory = 2048

  disks {
    virtio {
      virtio0 {
        disk {
          storage  = "local-lvm"
          size     = "20G"
          iothread = true
        }
      }
    }
    scsi {
      scsi0 {
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

  # Cloud-init
  ipconfig0  = "ip=10.60.60.12/24,gw=10.60.60.1"
  nameserver = "10.60.60.1"
  sshkeys    = var.sshkeys
  cipassword = var.cipassword

  ciupgrade = false
}

resource "proxmox_vm_qemu" "vm4" {
  vmid        = 113
  name        = "nixos-worker3"
  target_node = "pve"
  clone       = "debian-12-template"
  full_clone  = true
  tags        = "nixos;dmz;worker;nginx"

  agent    = 1
  os_type  = "l26"
  scsihw   = "virtio-scsi-single"
  vm_state = var.vm_state
  onboot   = true
  boot     = "order=virtio0"

  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  memory = 2048

  disks {
    virtio {
      virtio0 {
        disk {
          storage  = "local-lvm"
          size     = "20G"
          iothread = true
        }
      }
    }
    scsi {
      scsi0 {
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

  # Cloud-init
  ipconfig0  = "ip=10.60.60.13/24,gw=10.60.60.1"
  nameserver = "10.60.60.1"
  sshkeys    = var.sshkeys
  cipassword = var.cipassword

  ciupgrade = false
}

resource "proxmox_vm_qemu" "vm5" {
  vmid        = 114
  name        = "nixos-monitoring"
  target_node = "pve"
  clone       = "debian-12-template"
  full_clone  = true
  tags        = "nixos;monitoring;grafana;prometheus"

  agent    = 1
  os_type  = "l26"
  scsihw   = "virtio-scsi-single"
  vm_state = var.vm_state
  onboot   = true
  boot     = "order=virtio0"

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory = 4092

  disks {
    virtio {
      virtio0 {
        disk {
          storage  = "local-lvm"
          size     = "20G"
          iothread = true
        }
      }
    }
    scsi {
      scsi0 {
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

  # Cloud-init
  ipconfig0  = "ip=10.60.60.14/24,gw=10.60.60.1"
  nameserver = "10.60.60.1"
  sshkeys    = var.sshkeys
  cipassword = var.cipassword

  ciupgrade = false
}
