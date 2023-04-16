variable "cluster_name" {
    description = "The Name for the AKS cluster"
    default = "k8sCluster"
}

variable "env_name" {
    description = "The Environment for the AKS Cluster"
    default = "dev"
}

variable "instance_type" {
    description = "The Instance Type that run the AKS "
    default = "standard_d2_v2"
}