module "gitops_module" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  kubeseal_cert = module.gitops.sealed_secrets_cert

  instanceid = "masdemo"
  workspace_id = "demo"
  entitlement_key = module.cp_catalogs.entitlement_key
  /*db_user = var.database_username
  db_password = var.database_password
  db_cert = var.database_cert
  db_url = var.database_url */
  db_schema = ""
  db_secret = ""

  
}

resource null_resource write_namespace {
  depends_on = [module.gitops_module]

  provisioner "local-exec" {
    command = "echo -n '${module.gitops_module.namespace}' > .namespace"
  }
}
