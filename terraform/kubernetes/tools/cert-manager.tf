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

resource "helm_release" "letsencrypt_clusterissuer_federated_identity" {
  count           = var.custom_domain != null && var.custom_domain.dns_subscription_id != null && var.custom_domain.resource_group_name != null ? 1 : 0
  name            = "letsencrypt-clusterissuer-federated-identity"
  chart           = "../../../helm/charts/itscontained/raw"
  cleanup_on_fail = true
  namespace       = kubernetes_namespace.certificates.metadata[0].name

  values = [<<EOF
resources:
- apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: letsencrypt-${var.letsencypt_production ? "production" : "staging"}
  spec:
    acme:
      server: https://acme-${var.letsencypt_production ? "" : "staging-"}v02.api.letsencrypt.org/directory
      email: "hostmaster@${var.custom_domain.domain_name}"
      profile: tlsserver
      privateKeySecretRef:
        name: letsencrypt-${var.letsencypt_production ? "production" : "staging"}
      solvers:
      - dns01:
          azureDNS:
            resourceGroupName: ${var.custom_domain.resource_group_name}
            subscriptionID: ${var.custom_domain.dns_subscription_id}
            hostedZoneName: ${var.custom_domain.domain_name}
            environment: AzurePublicCloud
            managedIdentity:
              clientID: ${var.cert_manager_federated_identity_client_id}
EOF
  ]
  depends_on = [helm_release.istio_ingress]
}

resource "helm_release" "letsencrypt_istio_certificate" {
  count           = var.custom_domain != null ? 1 : 0
  name            = "letsencrypt-istio-cert"
  chart           = "../../../helm/charts/itscontained/raw"
  namespace       = kubernetes_namespace.istio_system.metadata[0].name
  cleanup_on_fail = true

  values = [<<EOF
resources:
- apiVersion: cert-manager.io/v1
  kind: Certificate
  metadata:
    name: ${var.custom_domain.domain_name}-tls
    namespace: ${kubernetes_namespace.istio_system.metadata[0].name}
  spec:
    secretName: ${var.custom_domain.domain_name}-tls
    duration: 2160h # 90d
    renewBefore: 360h # 15d
    commonName: ${var.custom_domain.domain_name}
    dnsNames:
      - ${var.custom_domain.domain_name}
    issuerRef:
      name: letsencrypt-${var.letsencypt_production ? "production" : "staging"}
      kind: ClusterIssuer
EOF
  ]
  depends_on = [helm_release.letsencrypt_clusterissuer_federated_identity]
}
