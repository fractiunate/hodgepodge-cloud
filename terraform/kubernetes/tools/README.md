## Get Kubeconfig Credentials

```bash
az login --use-device-code
az account set --subscription ${ARM_SUBSCRIPTION_ID}
az aks get-credentials --resource-group dev-fractiunate-aks-rg --name dev-aks-gitops-${RANDOM_STR} --overwrite-existing --admin


b64_cluster_host=$(cat ~/.kube/config | yq '.clusters[]|select(.name == "dev-aks-gitops-qcen").cluster.server' | base64 -w0)
b64_cluster_ca_certificate=$(cat ~/.kube/config | yq '.clusters[]|select(.name == "dev-aks-gitops-qcen").cluster.certificate-authority-data' | base64 -w0)
b64_client_certificate=$(cat ~/.kube/config | yq '.users[]|select(.name == "clusterAdmin_dev-fractiunate-aks-rg_dev-aks-gitops-qcen").user.client-certificate-data' | base64 -w0)
b64_client_key=$(cat ~/.kube/config | yq '.users[]|select(.name == "clusterAdmin_dev-fractiunate-aks-rg_dev-aks-gitops-qcen").user.client-key-data' | base64 -w0)



```