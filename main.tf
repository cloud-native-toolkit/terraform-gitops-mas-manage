locals {
  name           = "masauto-manage"
  tmp_dir        = "${path.cwd}/.tmp/${local.name}"
  yaml_dir       = "${local.tmp_dir}/chart/${local.name}"

  layer              = "services"
  type               = "instances"
  application_branch = "main"

# set values content for subscription
  values_content = {
    ibm_entitlement_secret = var.ibm_entitlement_secret
    mas_instance_id = var.mas_instance_id
    mas_workspace_id = var.mas_workspace_id
    db2_meta_storage_class = var.db2_meta_storage_class
    db2_data_storage_class = var.db2_data_storage_class
    mas_app_settings_demodata = var.demodata ? "true" : "false"
    db2_instance_name = var.db2_instance_name
    mas_app_channel = var.mas_app_channel
    mas_config_scope = var.mas_config_scope
    db2_dbname = var.db2_dbname
  }
}

resource null_resource create_instance_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

# Deploy Instance
resource gitops_module mas_manage {
  name        = local.name
  namespace   = var.core_namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer       = local.layer
  type        = local.type
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
