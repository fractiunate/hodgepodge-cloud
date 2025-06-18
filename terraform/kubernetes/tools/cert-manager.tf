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
    name: letsencrypt-staging
  spec:
    acme:
      server: https://acme-staging-v02.api.letsencrypt.org/directory
      email: "hostmaster@${var.custom_domain.domain_name}"
      profile: tlsserver
      privateKeySecretRef:
        name: letsencrypt-staging
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
