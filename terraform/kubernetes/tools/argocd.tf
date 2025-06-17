resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name            = "argocd"
  chart           = "argo-cd"
  version         = "8.1.0"
  repository      = "https://argoproj.github.io/argo-helm"
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  cleanup_on_fail = true

  values = [<<EOF
controller:
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"

server:
  resources:
    requests:
      memory: "64Mi"
      cpu: "50m"
    limits:
      memory: "128Mi"
      cpu: "100m"

repoServer:
  resources:
    requests:
      memory: "64Mi"
      cpu: "50m"
    limits:
      memory: "128Mi"
      cpu: "100m"

dex:
  enabled: false

notifications:
  enabled: false

redis:
  resources:
    requests:
      memory: "64Mi"
      cpu: "25m"
    limits:
      memory: "128Mi"
      cpu: "50m"
EOF
  ]
}
