/*resource "helm_release" "ingress" {
  name      = "ingress"
  chart     = "stable/nginx-ingress"
  namespace = "kube-system"
  timeout   = 1800

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_public_ip.ingress_ip,
  kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb]

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.ingress_ip.ip_address
  }
  set {
    name  = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group\""
    value = azurerm_resource_group.resource_group.name
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  chart      = "stable/jenkins"
  namespace  = "cicd"
  timeout    = 1800
  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_public_ip.ingress_ip, kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb, helm_release.ingress]
  values = [
    "${file("jenkins.values.yaml")}"
  ]
  set {
    name  = "master.ingress.hostName"
    value = "${azurerm_dns_a_record.jenkins.name}.${azurerm_dns_zone.dns_zone.name}"
  }
}

resource "helm_release" "istio_init" {
  name       = "istio-init"
  chart      = "../istio-init"
  version    = "1.2.2"
  namespace = "istio-system"

  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_public_ip.ingress_ip, kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb]

  values = [
    "${file("../istio-init/values.yaml")}"
  ]

  provisioner "local-exec" {
    command = "sleep 300"
  }
}

resource "helm_release" "istio" {
  name       = "istio"
  chart      = "../istio"
  version    = "1.2.2"
  namespace = "istio-system"

  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_public_ip.ingress_ip, kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb, helm_release.istio_init]

  values = [
    "${file("../istio/values-istio-demo.yaml")}"
  ]
}

resource "helm_release" "spinnaker" {
  name       = "spinnaker"
  chart      = "stable/spinnaker"
  namespace  = "cicd"
  timeout    = 1800
  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_public_ip.ingress_ip, kubernetes_cluster_role_binding.tiller_sa_cluster_admin_rb, helm_release.ingress]
  set {
    name  = "ingress.host"
    value = "${azurerm_dns_a_record.spinnaker_ingress.name}.${azurerm_dns_zone.dns_zone.name}"
  }
  set {
    name  = "ingressGate.host"
    value = "${azurerm_dns_a_record.spinnaker_ingress_gate.name}.${azurerm_dns_zone.dns_zone.name}"
  }
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingressGate.enabled"
    value = "true"
  }
}*/