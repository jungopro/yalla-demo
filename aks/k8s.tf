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