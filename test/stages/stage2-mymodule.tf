module "gitops_module" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  kubeseal_cert = module.gitops.sealed_secrets_cert
  server_name = module.gitops.server_name

  core_namespace = module.mas_core.namespace
  ibm_entitlement_secret = module.mas_core.entitlement_secret_name
  mas_instance_id = module.mas_core.mas_instance_id
  mas_workspace_id = module.mas_core.mas_workspace_id

  db2_meta_storage_class = module.storage_manager.rwx_storage_class
  db2_data_storage_class = module.storage_manager.block_storage_class
}
