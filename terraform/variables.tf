variable "pm_api_url" {}
variable "pm_api_token_id" {}
variable "pm_api_token_secret" {
  sensitive = true
}
variable "pm_tls_insecure" {
  type    = bool
  default = true
}

variable "sshkeys" {
  type    = string
  #default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBkMYwuNdqWYMYnW/xb5cqJWmn+0+vkwfJ7iLJjtAag0 alexborrazasm@gmail.com%0assh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB3IqxBfuCloPHqOvbr7k2yXBy01H3PMMPggeCwerZCR mario.l.a3094@gmail.com"
  default = ""
}

variable "cipassword" {
  type      = string
  sensitive = true
}

variable "vm_state" {
  type    = string
  default = "running"
}