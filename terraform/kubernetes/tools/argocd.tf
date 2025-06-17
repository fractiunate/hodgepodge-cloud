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
  insecure: true
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


resource "helm_release" "argo_route" {
  name            = "argocd-route"
  chart           = "../../../helm/charts/itscontained/raw"
  cleanup_on_fail = true
  namespace       = kubernetes_namespace.argocd.metadata[0].name

  values = [<<EOF
resources:
- apiVersion: networking.istio.io/v1
  kind: VirtualService
  metadata:
    name: argocd-route
    namespace: ${kubernetes_namespace.argocd.metadata[0].name} 
  spec:
    gateways:
    - istio-system/gateway
    hosts:
    - argocd.dev.fractiunate.me
    http:
    - name: "argocd-route"
      match:
      - uri:
          prefix: "/"
      route:
      - destination:
          host: argocd-server.${kubernetes_namespace.argocd.metadata[0].name}.svc.cluster.local
          port:
            number: 80
EOF
  ]
  depends_on = [helm_release.istio_ingress]
}
