# The resource here will create a local file populated with the kube configuration to generate access for the cluster.
# depends_on: Here you want the cluster to be created first before fetching the kubeconfig value. 
# Otherwise, Terraform may create an empty file.
resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.k8sCluster]
  filename = "kubeconfig"
  content = azurerm_kubernetes_cluster.k8sCluster.kube_config_raw
}