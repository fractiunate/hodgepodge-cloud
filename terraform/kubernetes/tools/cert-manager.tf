resource "kubernetes_namespace" "certificates" {
  metadata {
    name = "certificates"
  }
}

resource "helm_release" "certmanager" {
  name            = "cert-manager"
  chart           = "jetstack/cert-manager"
  version         = "1.18.0"
  repository      = "https://charts.jetstack.io"
  namespace       = kubernetes_namespace.certmanager.metadata[0].name
  cleanup_on_fail = true
}
