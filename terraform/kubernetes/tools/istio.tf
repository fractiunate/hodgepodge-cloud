resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name            = "istio-base"
  chart           = "base"
  repository      = "https://istio-release.storage.googleapis.com/charts"
  version         = "1.26.1"
  cleanup_on_fail = true
  namespace       = kubernetes_namespace.istio_system.metadata[0].name
}
