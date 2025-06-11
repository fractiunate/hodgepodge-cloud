output "whitelist_ips_empty" {
  value = var.whitelist_ips != [] ? ["default_deny_all"] : []
}
