## Get Kubeconfig Credentials

```bash
CLUSTER_NAME=dev-aks-gitops-iojg
az login --use-device-code
az account set --subscription ${ARM_SUBSCRIPTION_ID}
az aks get-credentials --resource-group dev-fractiunate-aks-rg --name ${CLUSTER_NAME} --overwrite-existing --admin

echo "b64_cluster_host=$(cat ~/.kube/config | yq '.clusters[]|select(.name == "dev-aks-gitops-iojg").cluster.server' | base64 -w0)" > tmp/credentials
echo "b64_cluster_ca_certificate=$(cat ~/.kube/config | yq '.clusters[]|select(.name == "dev-aks-gitops-iojg").cluster.certificate-authority-data')" >> tmp/credentials
echo "b64_client_certificate=$(cat ~/.kube/config | yq '.users[]|select(.name == "clusterAdmin_dev-fractiunate-aks-rg_dev-aks-gitops-iojg").user.client-certificate-data')" >> tmp/credentials
echo "b64_client_key=$(cat ~/.kube/config | yq '.users[]|select(.name == "clusterAdmin_dev-fractiunate-aks-rg_dev-aks-gitops-iojg").user.client-key-data')" >> tmp/credentials



```