module "odf" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-ibm-odf"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  namespace = module.gitops_namespace.name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  ibmcloud_api_key = var.ibmcloud_api_key

  # ODF specific variables
  osdSize = var.osdSize
}
