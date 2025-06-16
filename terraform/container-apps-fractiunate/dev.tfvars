resource_group_name="dev-fractiunate-container-apps-rg"
location="West Europe"
container_app_name="fractiunate"
container_app_image="fractiunate/clients-fractiunate-ssr:main"
container_app_ingress = {
  target_port = 3000
  external_enabled = true
  traffic_weight = {
    percentage      = 100
    latest_revision = true
  }
}