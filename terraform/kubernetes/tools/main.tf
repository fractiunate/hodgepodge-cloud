resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name            = "argocd"
  chart           = "argo/argo-cd"
  version         = "8.1.0"
  repository      = "https://argoproj.github.io/argo-helm"
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  cleanup_on_fail = true
}
