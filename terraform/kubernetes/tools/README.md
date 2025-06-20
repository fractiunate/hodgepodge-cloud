## Get Kubeconfig Credentials

```bash
CLUSTER_NAME=dev-aks-gitops-dxzd

az login --use-device-code
az account set --subscription ${ARM_SUBSCRIPTION_ID}
az aks get-credentials --resource-group dev-fractiunate-aks-rg --name ${CLUSTER_NAME} --overwrite-existing --admin

kubeconfig=~/.kube/config
echo "b64_cluster_host=$(cat $kubeconfig | yq '.clusters[]|select(.name == "dev-aks-gitops-dxzd").cluster.server' | base64 -w0)" > tmp/credentials
echo "b64_cluster_ca_certificate=$(cat $kubeconfig | yq '.clusters[]|select(.name == "dev-aks-gitops-dxzd").cluster.certificate-authority-data')" >> tmp/credentials
echo "b64_client_certificate=$(cat $kubeconfig | yq '.users[]|select(.name == "clusterAdmin_dev-fractiunate-aks-rg_dev-aks-gitops-dxzd").user.client-certificate-data')" >> tmp/credentials
echo "b64_client_key=$(cat $kubeconfig | yq '.users[]|select(.name == "clusterAdmin_dev-fractiunate-aks-rg_dev-aks-gitops-dxzd").user.client-key-data')" >> tmp/credentials
```


##  Cert-Manager

Setup workload identity and issue a dns challenge certificate, read more: https://cert-manager.io/docs/tutorials/getting-started-aks-letsencrypt/#reconfigure-the-cluster

Set `CERT_MANAGER_FEDERATED_IDENTITY_CLIENT_ID ` in github environment after re-deployed base infra.

## Ory Identity & Gatekeeper (WIP)

REF:  [Istio setup and best practices](https://github.com/ory/oathkeeper/issues/624)
