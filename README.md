# Yalla-Semo

Yalla DevOps 2019 Demo

**Please note that running this demo will incur costs in Azure**

## Prerequisites

- Azure Account
- Terraform Knowledge
- [Terraform Service Account with proper permissions on the Azure Subscription](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html)

## Setup a cluster using Terraform

### Clone the repo and switch to the AKS folder

```bash
git clone https://github.com/jungopro/yalla-demo.git
cd yalla-demo/aks
```

### TerraformIT

```bash
terraform init
terraform apply -var=client_secret=<your-client-secret> -var=kubeconfig_path="/root/.kube/demo-aks.yaml"
```

### Connect to your cluster

- add the new cluster to your config (e.g. `export KUBECONFIG=/root/.kube/demo-aks.yaml`)
- switch to your cluster (e.g. `kubectl config set-context demo-aks`)
- verify cluster is healthy and nodes are up (`kubectl get nodes`)

### Deploy Istio

```bash
helm init --service-account tiller
kubectl get pod -n kube-system -l name=tiller # verify tiller is running
helm version
cd ../
helm install istio-init/ --name istio-init --namespace istio-system
kubectl get pod -n istio-system
kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l # verify 53 CRDs created
helm install istio/ --name istio --namespace istio-system --values istio/values-istio-demo.yaml --set gateways.istio-ingressgateway.loadBalancerIP="<static-ip-in-aks-resource-group>" --debug
kubectl get pod -n istio-system # make sure all pods are running
kubectl get svc -n istio-system # make sure istio-ingress has a valid loadbalancer external IP
```

### Enable automatic sidecar injection

```bash
kubectl label namespace default istio-injection=enabled
```

## Bookinfo

### Service Mesh Visualization

```bash
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001 # open http://localhost:20001/kiali/console/ with admin:admin
```

### Distributed Tracing

```bash
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 # jaeger
```

### Metrics

```bash
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 # prometheus

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 # grafana
```

### Traffic Routing

- Route only to v1:
  ```bash
  kubectl apply -f 04-virtual-service-all-v1.yaml --namespace default
  ```

- Route user Json to v1 and v2
  ```bash
  kubectl apply -f 05-virtual-service-reviews-test-v2.yaml --namespace default
  ```

### Remove all resources and destroy the cluster

```bash
cd aks
terraform destroy -var=client_secret=<your-client-secret> -var=kubeconfig_path="/root/.kube/demo-aks.yaml"
```