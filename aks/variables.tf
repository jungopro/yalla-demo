variable "client_secret" {
  description = "client secret of an azure account that can provision the infra (contrib permissions on the subscription level is recommenfed)"
}

variable "location" {
  description = "Azure Location"
  default = "west europe"
}

variable "kubeconfig_path" {
  description = "full path to save the kubeconfig in (e.g. /root/.kube/mycluster.yaml). make sure to add this file to KUBECONFIG (e.g. export KUBECONFIG=$KUBECONFIG:/root/.kube/mycluster.yaml) in order to add it to your list of clusters"
}

variable "node_count" {
  description = "the number of worker nodes in the pool"
  default = 3
}

variable "max_pods" {
  description = "The maximum number of pods that can run on each agent"
  default = 30
}

variable "aks_rg_name" {
  description = "the name of the rg for the aks cluster"
  default = "aks"
}

variable "aks_subnet_name" {
  description = "the name of the subnet for the aks nodes"
  default = "aks-subnet"
}

variable "vnet_name" {
  description = "the name of the vnet"
  default = "aks-vnet"
}

variable "vnet_address_space" {
  description = "list of address spaces for the vnet"
  type        = list(string)
  default = ["10.0.0.0/8"]
}

variable "aks_subnet_address" {
  description = "the network address for the aks subnet"
  default = "10.200.0.0/22"
}

variable "vk_subnet_address" {
  description = "the network address for the aks subnet"
  default = "10.241.0.0/24"
}

variable "cluster_name" {
  description = "the name of the aks cluster. also the dns prefix"
  default = "playks"
}

variable "kubernetes_version" {
  description = "the kubernetes version to use"
  default = "1.14.5"
}

variable "vm_size" {
  default = "Standard_B2ms"
}

variable "ssh_public_key" {}