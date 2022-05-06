locals {
  name           = "ibm-masapp-manage"
  bin_dir        = module.setup_clis.bin_dir
  tmp_dir        = "${path.cwd}/.tmp/${local.name}"
  yaml_dir       = "${local.tmp_dir}/chart/${local.name}"
  secret_dir     = "${local.tmp_dir}/secrets"
  db_secret_name = "${var.instanceid}-jdbc-creds-wsapp-manage"
  jdbc_name      = "${var.instanceid}-jdbc-wsapp-${var.workspace_id}-${var.appid}"

  layer              = "services"
  type               = "operators"
  application_branch = "main"
  appname            = "ibm-mas-${var.appid}"
  namespace          = "mas-${var.instanceid}-${var.appid}"
  core-namespace     = "mas-${var.instanceid}-core"
  layer_config       = var.gitops_config[local.layer]
  installPlan        = var.installPlan
 
# set values content for subscription
  values_content = {
    subscriptions = {
        masapp = {
          name = local.appname
          appid = var.appid
          instanceid = var.instanceid
          namespace = local.namespace
          core-namespace = local.core-namespace
          workspaceid = var.workspace_id
          subscription = {
            channel = var.channel
            installPlanApproval = local.installPlan
            source = var.catalog
            sourceNamespace = var.catalog_namespace
          }
        }
        database = {
          url = var.db_url
          secretname = local.db_secret_name
          jdbcname = local.jdbc_name

        }
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

# Add SBO module
module "sbo" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-service-binding-operator.git"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  server_name = var.server_name
  kubeseal_cert = var.kubeseal_cert
  namespace = "openshift-operators"
} 

# Add jdbc config secret
resource null_resource create_secret {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-secret.sh '${local.core-namespace}' '${var.db_user}' '${var.db_password}' '${local.db_secret_name}' '${local.secret_dir}' '${local.name}-password'"
  }
}

module seal_secrets {
  depends_on = [null_resource.create_secret]

  source = "github.com/cloud-native-toolkit/terraform-util-seal-secrets.git"

  source_dir    = local.secret_dir
  dest_dir      = "${local.yaml_dir}/templates"
  kubeseal_cert = var.kubeseal_cert
  label         = local.name
}

# build jdbc config yaml



# Add values for charts
resource "null_resource" "deployAppVals" {
  depends_on = [module.pullsecret]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
      DB_CERT = var.db_cert
    }
  }
}

# Deploy
resource gitops_module masapp {
  depends_on = [null_resource.deployAppVals,module.seal_secrets,module.sbo]

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
