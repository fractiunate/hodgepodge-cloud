resource_group_name="dev-example-container-apps-rg"
location="West Europe"
container_app_name="nginx"
container_app_image="nginx:latest"
container_app_ingress = {
  target_port = 80
  traffic_weight = {
    percentage      = 100
    latest_revision = true
  }
}