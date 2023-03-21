module "mas_core" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-mas-core"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  kubeseal_cert = module.gitops.sealed_secrets_cert
  server_name = module.gitops.server_name

  catalog_name = module.toolkit_catalog.name
  entitlement_key = var.cp_entitlement_key
  uds_contact_email = "someone@somewhere.com"
  uds_contact_first_name = "Test"
  uds_contact_last_name = "User"
  mongodb_storage_class = module.storage_manager.block_storage_class
  uds_storage_class = module.storage_manager.block_storage_class
  host_id = var.host_id
  license_key = var.license_key
}
