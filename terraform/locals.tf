locals {
  networks = {
    wan = {
      id     = 0
      bridge = "vmbr0"
    }
    lan = {
      id     = 1
      bridge = "vmbr1"
    }
    dmz = {
      id     = 2
      bridge = "vmbr2"
    }
  }
}