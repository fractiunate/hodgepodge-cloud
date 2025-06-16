variable "b64_cluster_host" {
  description = "Base64 encoded cluster host URL"
  type        = string
}

variable "b64_client_certificate" {
  description = "Base64 encoded cluster client certificate"
  type        = string
}

variable "b64_client_key" {
  description = "Base64 encoded cluster client key"
  type        = string
}

variable "b64_cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  type        = string
}
