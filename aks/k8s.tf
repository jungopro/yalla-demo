## Create

resource "local_file" "kubeconfig" {
  # kube config
  filename = var.kubeconfig_path
  content  = azurerm_kubernetes_cluster.aks.kube_config_raw

  # helm init
  provisioner "local-exec" {
    command = "helm init --client-only"
    environment = {
      KUBECONFIG = var.kubeconfig_path
    }
  }
}

resource "kubernetes_service_account" "tiller_sa" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }

  depends_on = [azurerm_kubernetes_cluster.aks, local_file.kubeconfig]
}

resource "kubernetes_cluster_role_binding" "tiller_sa_cluster_admin_rb" {
  metadata {
    name = "tiller-cluster-role"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller_sa.metadata.0.name
    namespace = "kube-system"
    api_group = ""
  }

  depends_on = [azurerm_kubernetes_cluster.aks, local_file.kubeconfig]
}

/*resource "kubernetes_namespace" "hipster" {
  metadata {

    labels = {
      istio-injection = "enabled"
    }

    name = "hipster"
  }

  depends_on = [azurerm_kubernetes_cluster.aks, local_file.kubeconfig]
}

data "kubernetes_service" "istio_ingressgateway" {
  metadata {
    name = "istio-ingressgateway"
    namespace = "istio-system"
  }

  depends_on = [null_resource.istio]
}

resource "null_resource" "hipster" {
  
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${var.kubeconfig_path} -f ${path.root}/../hipster-app/kubernetes-manifests.yaml -n hipster"
  }

  depends_on = [kubernetes_namespace.hipster, helm_release.istio]
}

resource "null_resource" "istio" {
  
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${var.kubeconfig_path} -f ${path.root}/../hipster-app/istio-manifests.yaml -n hipster"
  }

  depends_on = [kubernetes_namespace.hipster, helm_release.istio]
}*/