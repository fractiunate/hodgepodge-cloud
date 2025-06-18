## Get Kubeconfig Credentials

```bash
CLUSTER_NAME=dev-aks-gitops-iojg
az login --use-device-code
az account set --subscription ${ARM_SUBSCRIPTION_ID}
az aks get-credentials --resource-group dev-fractiunate-aks-rg --name ${CLUSTER_NAME} --overwrite-existing --admin

kubeconfig=~/.kube/config
echo "b64_cluster_host=$(cat $kubeconfig | yq '.clusters[]|select(.name == "dev-aks-gitops-ijbv").cluster.server' | base64 -w0)" > tmp/credentials
echo "b64_cluster_ca_certificate=$(cat $kubeconfig | yq '.clusters[]|select(.name == "dev-aks-gitops-ijbv").cluster.certificate-authority-data')" >> tmp/credentials
echo "b64_client_certificate=$(cat $kubeconfig | yq '.users[]|select(.name == "clusterAdmin_dev-fractiunate-aks-rg_dev-aks-gitops-ijbv").user.client-certificate-data')" >> tmp/credentials
echo "b64_client_key=$(cat $kubeconfig | yq '.users[]|select(.name == "clusterAdmin_dev-fractiunate-aks-rg_dev-aks-gitops-ijbv").user.client-key-data')" >> tmp/credentials
```


##  Cert-Manager

Setup workload identity and issue a dns challenge certificate, read more: https://cert-manager.io/docs/tutorials/getting-started-aks-letsencrypt/#reconfigure-the-cluster