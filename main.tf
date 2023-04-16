# Since the module is reusable, you can create more than a single cluster and environment
module "prod_cluster" {
  source = "./my-module"
  env_name = "prod"
  cluster_name = "AksCluster"
  instance_type = "standard_d2_v2"
}

module "env_cluster" {
  source = "./my-module"
  env_name = "dev"
  cluster_name = "AksCluster"
  instance_type = "standard_d11_v2"
}