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
  wait            = true
  namespace       = kubernetes_namespace.istio_system.metadata[0].name
}


resource "helm_release" "istiod" {
  name            = "istiod"
  chart           = "istiod"
  repository      = "https://istio-release.storage.googleapis.com/charts"
  version         = "1.26.1"
  cleanup_on_fail = true
  wait            = true
  namespace       = kubernetes_namespace.istio_system.metadata[0].name

  set = [
    {
      # Add a pod annotation which allows autoscaler to evict any Pods with injected Istio-proxy sidecar
      # cf. https://github.com/istio/istio/issues/19395
      # Could go wrong in case any pod uses local storage or similar things
      name  = "sidecarInjectorWebhook.injectedAnnotations.cluster-autoscaler\\.kubernetes\\.io/safe-to-evict"
      value = "true"
    },
    {
      name  = "revision"
      value = "v1"
    }
  ]
  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name            = "istio-ingressgateway"
  chart           = "gateway"
  repository      = "https://istio-release.storage.googleapis.com/charts"
  version         = "1.26.1"
  cleanup_on_fail = true
  wait            = true
  namespace       = kubernetes_namespace.istio_system.metadata[0].name
  set = [
    {
      name  = "revision"
      value = "v1"
    }
  ]
  depends_on = [helm_release.istiod]
}

resource "helm_release" "istio_gateway" {
  name            = "default-gateway"
  chart           = "../../../helm/charts/itscontained/raw"
  cleanup_on_fail = true
  namespace       = kubernetes_namespace.istio_system.metadata[0].name

  values = [<<EOF
resources:
- apiVersion: networking.istio.io/v1
  kind: Gateway
  metadata:
    name: gateway
    namespace: ${kubernetes_namespace.istio_system.metadata[0].name}
  spec:
    selector:
      app: istio-ingressgateway
    servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
      - "*.dev.fractiunate.me"
      %{if var.tls_redirect}
      tls:
        httpsRedirect: true
      %{endif}
    - port:
        number: 443
        name: https-443
        protocol: HTTPS
      hosts:
      - "*.dev.fractiunate.me"
      tls:
        mode: SIMPLE
        credentialName: ${var.custom_domain.domain_name}-tls
EOF
  ]
  depends_on = [helm_release.istio_ingress]
}
