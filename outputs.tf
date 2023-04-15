resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.k8sCluster]
  filename = "kubeconfig"
  content = azurerm_kubernetes_cluster.k8sCluster.kube_config_raw
}