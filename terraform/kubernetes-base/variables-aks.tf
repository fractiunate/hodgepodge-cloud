variable "kubernetes_version" {
  default     = "1.31"
  description = "The version of Kubernetes to use for the AKS cluster."
}

variable "sla_sku" {
  description = "Define the SLA under which the managed master control plane of AKS is running."
  type        = string
  default     = "Free"
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs that will be granted admin access to the AKS cluster."
  type        = list(string)
  default     = []
}

variable "default_node_pool" {
  description = "Configuration for the default node pool in the AKS cluster."
  type = object({
    vm_size = string
  })
  default = {
    vm_size = "Standard_B2s"
  }
}
