variable "pm_api_url" {}
variable "pm_api_token_id" {}
variable "pm_api_token_secret" {
  sensitive = true
}
variable "pm_tls_insecure" {
  type    = bool
  default = true
}