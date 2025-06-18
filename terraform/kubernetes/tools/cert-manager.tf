resource "kubernetes_namespace" "certificates" {
  metadata {
    name = "certificates"
  }
}

resource "helm_release" "certmanager" {
  name            = "cert-manager"
  chart           = "cert-manager"
  version         = "1.18.0"
  repository      = "https://charts.jetstack.io"
  namespace       = kubernetes_namespace.certificates.metadata[0].name
  cleanup_on_fail = true

  values = [<<EOF
podLabels:
  azure.workload.identity/use: "true"
serviceAccount:
  labels:
    azure.workload.identity/use: "true"
crds:
  enabled: true
  keep: true
EOF
  ]
}
