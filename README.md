# Yalla-Demo

Yalla DevOps 2019 Demo

**Please note that running this demo will incur costs in Azure**

## Prerequisites

- Azure Account
- Terraform Knowledge
- Terraform Cloud Account for remote state (Free, see [here](https://www.terraform.io/docs/enterprise/index.html))
- Terraform Service Account with proper permissions on the Azure Subscription. See [here](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html)
- kubectl [installed](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Setup a cluster using Terraform

### Clone the repo and switch to the AKS folder

```console
git clone https://github.com/jungopro/yalla-demo.git
cd yalla-demo/aks
```

### TerraformIT

```console
terraform init
terraform apply -var=client_secret=<your-client-secret> -var=kubeconfig_path="/root/.kube/demo-aks.yaml" -var=ssh_public_key="/full/path/to/ssh/publc/key.pub"
```

### Connect to your cluster

- add the new cluster to your config (e.g. `export KUBECONFIG=$KUBECONFIG:/root/.kube/demo-aks.yaml`)
- switch to your cluster (e.g. `kubectl config set-context demo-aks`)
- verify cluster is healthy and nodes are up (`kubectl get nodes`)

### Deploy Istio

```console
helm init --service-account tiller
kubectl get pod -n kube-system -l name=tiller # verify tiller is running
helm version
cd ../
helm install istio-init/ --name istio-init --namespace istio-system
kubectl get pod -n istio-system
kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l # verify 23 CRDs created
helm install istio/ --name istio --namespace istio-system --values istio/values-istio-demo.yaml --set gateways.istio-ingressgateway.loadBalancerIP="{external_ip output from terraform run}" --debug
kubectl get pod -n istio-system # make sure all pods are running
kubectl get svc -n istio-system # make sure istio-ingress has a valid loadbalancer external IP
```

### Enable automatic sidecar injection

```console
kubectl label namespace default istio-injection=enabled
```

## Applications

### Installation

```console
kubectl apply -f 01-bookinfo.yaml
kubectl apply -f 02-bookinfo-gateway.yaml
kubectl apply -f 03-destination-rule-all.yaml
kubectl create ns hipster
kubectl label namespace hipster istio-injection=enabled
kubectl apply -f hipster-shop/ --namespace hipster
```

- Verify the **bookinfo** application is working by navigating to http://*{external_ip output from terraform run}*/productpage
- Verify the **hipster shop** application is working by navigating to http://*{external_ip output from terraform run}*:31400

### Service Mesh Visualization

```console
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001 # open http://localhost:20001/kiali/console/ with admin:admin
```

### Distributed Tracing

```console
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 # jaeger
```

### Metrics

```console
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 # prometheus

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 # grafana
```

### Traffic Shifting (Bookinfo)

- Route only to v1:
  ```console
  kubectl apply -f 04-virtual-service-all-v1.yaml --namespace default
  ```

- Route user Jason to v1 and v2
  ```console
  kubectl apply -f 05-virtual-service-reviews-test-v2.yaml --namespace default
  ```

- Route 80% of traffic to v1 and 20% to v2 (reviews service)
  ```console
  kubectl apply -f 06-virtual-service-reviews-80-20.yaml --namespace default
  ```

- Route 90% of traffic to v1 and 10% to v2 (reviews service)
  ```console
  kubectl apply -f 07-virtual-service-reviews-90-10.yaml --namespace default
  ```

### Fault injection (Bookinfo)

Prevent user Jason from reaching the ratings service

```console
kubectl delete -f 04-virtual-service-all-v1.yaml --namespace default
kubectl delete -f 05-virtual-service-reviews-test-v2.yaml --namespace default
kubectl delete -f 06-virtual-service-reviews-80-20.yaml --namespace default
kubectl delete -f 07-virtual-service-reviews-90-10.yaml --namespace default
kubectl apply -f 03-destination-rule-all.yaml
kubectl apply -f 08-virtual-service-ratings-test-abort.yaml --namespace default
```

### Remove all resources and destroy the cluster

```console
cd aks
helm delete istio --purge
terraform destroy -var=client_secret=<your-client-secret> -var=kubeconfig_path="/root/.kube/demo-aks.yaml"
```
