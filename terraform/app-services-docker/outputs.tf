output "whitelist_ips_empty" {
  value = length(var.whitelist_ips) > 0 ? ["default_deny_all"] : []
}

output "whitelist_ips" {
  value = var.whitelist_ips
}
