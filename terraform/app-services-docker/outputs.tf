output "whitelist_ips_empty" {
  value = var.whitelist_ips != [] ? ["default_deny_all"] : []
}

output "whitelist_ips" {
  value = var.whitelist_ips
}
