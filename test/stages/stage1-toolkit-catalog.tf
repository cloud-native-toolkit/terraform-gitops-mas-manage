module "toolkit_catalog" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-toolkit-catalog.git"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
}