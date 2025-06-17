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


resource "helm_release" "istiod" {
  name            = "istiod"
  chart           = "istiod"
  repository      = "https://istio-release.storage.googleapis.com/charts"
  version         = "1.26.1"
  cleanup_on_fail = true
  namespace       = kubernetes_namespace.istio_system.metadata[0].name

  set = [
    {
      # Add a pod annotation which allows autoscaler to evict any Pods with injected Istio-proxy sidecar
      # cf. https://github.com/istio/istio/issues/19395
      # Could go wrong in case any pod uses local storage or similar things
      name  = "sidecarInjectorWebhook.injectedAnnotations.cluster-autoscaler\\.kubernetes\\.io/safe-to-evict"
      value = "true"
    }
  ]
  depends_on = [helm_release.istio_base]
}
