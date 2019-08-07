## Vars

variable "client_secret" {}

variable "location" {
  description = "Azure Location"
}

variable "kubeconfig_path" {
  description = "full path to save the kubeconfig in (e.g. /root/.kube/mycluster.yaml). make sure to add this file to KUBECONFIG (e.g. export KUBECONFIG=$KUBECONFIG:/root/.kube/mycluster.yaml) in order to add it to your list of clusters"
}

variable "node_count" {
  description = "the number of worker nodes in the pool"
}

variable "gpu_node_count" {
  description = "the number of worker nodes in the pool"
}

variable "max_pods" {
  description = "The maximum number of pods that can run on each agent"
}

variable "aks_rg_name" {
  description = "the name of the rg for the aks cluster"
}

variable "aks_subnet_name" {
  description = "the name of the subnet for the aks nodes"
}

variable "vk_subnet_name" {
  description = "the name of the subnet for the virtual kubelet"
}

variable "vnet_name" {
  description = "the name of the vnet"
}

variable "vnet_address_space" {
  description = "list of address spaces for the vnet"
  type        = list(string)
}

variable "aks_subnet_address" {
  description = "the network address for the aks subnet"
}

variable "vk_subnet_address" {
  description = "the network address for the aks subnet"
}

variable "cluster_name" {
  description = "the name of the aks cluster. also the dns prefix"
}

variable "kubernetes_version" {
  description = "the kubernetes version to use"
}

variable "vm_size" {}

variable "ssh_public_key" {}

variable "zone_name" {}


variable "profiles" {
  default = [
    {
      name            = "pool2"
      count           = 2
      vm_size         = "Standard_B2s"
      os_type         = "Linux"
      os_disk_size_gb = 30
      max_pods        = 40
    },
    {
      name            = "pool3"
      count           = 3
      vm_size         = "Standard_B2s"
      os_type         = "Linux"
      os_disk_size_gb = 30
      max_pods        = 50
    },
    {
      name            = "pool4"
      count           = 4
      vm_size         = "Standard_B2s"
      os_type         = "Linux"
      os_disk_size_gb = 30
      max_pods        = 60
    },
  ]
}