locals {
  name           = "ibm-masapp-manage"
  operator_name  = "ibm-masapp-manage-operator"
  bin_dir        = module.setup_clis.bin_dir
  tmp_dir        = "${path.cwd}/.tmp/${local.name}"
  yaml_dir       = "${local.tmp_dir}/chart/${local.name}"
  operator_yaml_dir = "${local.tmp_dir}/chart/${local.operator_name}"
  secret_dir        = "${path.cwd}/.tmp/${local.namespace}/${local.name}/secrets"
  workspace_name    = "${var.instanceid}-${var.workspace_id}"
  cr_secret_name    = "${var.workspace_id}-${var.appid}-encryptionsecret"

  layer              = "services"
  type               = "instances"
  operator_type      = "operators"
  application_branch = "main"
  appname            = "ibm-mas-${var.appid}"
  namespace          = "mas-${var.instanceid}-${var.appid}"
  core-namespace     = "mas-${var.instanceid}-core"
  layer_config       = var.gitops_config[local.layer]
  installPlan        = var.installPlan
 
# set values content for subscription
  values_content = {
        masapp = {
          name = local.appname
          appid = var.appid
          instanceid = var.instanceid
          namespace = local.namespace
          core-namespace = local.core-namespace
          workspaceid = var.workspace_id
          demodata = var.demodata
          reuse_db = var.reuse_db
          cr_secret_name = local.cr_secret_name
        }
        workspace = {
          name = local.workspace_name
          dbschema = var.db_schema
        }
    }
  values_content_operator = {
        masapp = {
          name = local.appname
        }
        subscription = {
          channel = var.channel
          installPlanApproval = local.installPlan
          source = var.catalog
          sourceNamespace = var.catalog_namespace
        }
    }

} 

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}


# create namespace for mas application
module masappNamespace {
  source = "github.com/cloud-native-toolkit/terraform-gitops-namespace.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  name = "${local.namespace}"
  create_operator_group = true
}


# add entitlement secret
module "pullsecret" {
  depends_on = [module.masappNamespace]

  source = "github.com/cloud-native-toolkit/terraform-gitops-pull-secret.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  server_name = var.server_name
  kubeseal_cert = var.kubeseal_cert
  
  namespace = module.masappNamespace.name
  docker_server = "cp.icr.io"
  docker_username = "cp"
  docker_password = var.entitlement_key
  secret_name = "ibm-entitlement"
}

# If reusing database then need to create secret for encryption keys
resource null_resource create_secret {
  count = var.reuse_db ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-secret.sh '${local.namespace}' '${var.crypto_key}' '${var.cryptox_key}' '${local.cr_secret_name}' '${local.secret_dir}' '${local.name}-password'"
  }
}

module seal_secrets {
  count = var.reuse_db ? 1 : 0
  depends_on = [null_resource.create_secret]

  source = "github.com/cloud-native-toolkit/terraform-util-seal-secrets.git"

  source_dir    = local.secret_dir
  dest_dir      = "${local.operator_yaml_dir}/templates"
  kubeseal_cert = var.kubeseal_cert
  label         = local.operator_name
}



# Add SBO module
module "sbo" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-service-binding-operator.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  server_name = var.server_name
  kubeseal_cert = var.kubeseal_cert
  namespace = "openshift-operators"
} 

# Add JDBC Config
module "jdbc_config"{
  source = "github.com/cloud-native-toolkit/terraform-gitops-mas-jdbc.git"

    gitops_config = var.gitops_config
    git_credentials = var.git_credentials
    server_name = var.server_name
    kubeseal_cert = var.kubeseal_cert

    instanceid = var.instanceid
    workspace_id = var.workspace_id
    db_user = var.db_user
    db_password = var.db_password
    db_cert = var.db_cert
    db_url = var.db_url
}


# Add values for operator chart
resource "null_resource" "deployAppValsOperator" {

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-operator-yaml.sh '${local.operator_name}' '${local.operator_yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content_operator)
    }
  }
}


# Add values for instance charts
resource "null_resource" "deployAppVals" {

  triggers = {
    addons = join(",", var.addons)
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}' '${self.triggers.addons}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

# Deploy Operator
resource gitops_module masapp_operator {
  depends_on = [null_resource.deployAppValsOperator, module.sbo, module.jdbc_config, module.pullsecret]

  name        = local.operator_name
  namespace   = local.namespace
  content_dir = local.operator_yaml_dir
  server_name = var.server_name
  layer       = local.layer
  type        = local.operator_type
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

# Deploy Instance
resource gitops_module masapp {
  depends_on = [gitops_module.masapp_operator]

  name        = local.name
  namespace   = local.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer       = local.layer
  type        = local.type
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
