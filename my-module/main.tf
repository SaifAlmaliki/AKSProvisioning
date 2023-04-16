terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group along with its required parameters.
resource "azurerm_resource_group" "aks-rg" {
  name = "aksRG-${var.env_name}"
  location = "West Europe"
  tags = {
    Owner="saif.almaliki@pwc.com"
  }
}

# Kubernetes  Cluster
# The 'k8sCluster' is the locally given name for that resource that is only to be used as a reference inside the scope of the module.
# The name and dns_prefix are used to define the cluster's name and DNS name
resource "azurerm_kubernetes_cluster" "k8sCluster" {
  name = "${var.cluster_name}-${var.env_name}"
  location = azurerm_resource_group.aks-rg.location
  resource_group_name = azurerm_resource_group.aks-rg.name
  dns_prefix = "k8sCluster"
  tags = azurerm_resource_group.aks-rg.tags

  # Enable the Ingress controller for the AKS cluster.
  # This flag installs Ingress Nginx and also installs the ExternalDNS that can be used to manage DNS entries automatically.
  http_application_routing_enabled = true

  # In the 'default_node_pool' you are defining the specs for the worker nodes.
  default_node_pool {
    name = "default"
    node_count = 2
    vm_size = var.instance_type
  }
  # define the type of the identity, which is 'SystemAssigned'.
  # This means that Azure will automatically create the required roles and permissions,
  # and you won't need to manage any credentials.
  identity {
    type = "SystemAssigned"
  }
}

/*
# Modify the cluster by Adding another - more memory-optimized node pool to your cluster for your memory-hungry applications.
resource "azurerm_kubernetes_cluster_node_pool" "memoryOptimizedPoll" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8sCluster.id
  name = "memoryopt"
  node_count = 1
  vm_size = "standard_d11_v2"
}
*/