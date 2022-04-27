locals {
  //name          = "mas-appdeploy"
  name          = "ibm-masapp-manage"
  bin_dir       = module.setup_clis.bin_dir
  tmp_dir       = "${path.cwd}/.tmp/${local.name}"
  yaml_dir      = "${local.tmp_dir}/chart/${local.name}"
  //inst_dir      = "${local.yaml_dir}/instance"
  
  //chart_nameSub     = "ibm-masapp-operator-subscription"
  //chart_nameInst    = "ibm-masapp-operator-instance"
  //chart_name         = local.name
  //yaml_dirSub       = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_nameSub}/"
  //yaml_dirInst      = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_nameInst}/"
  //yaml_dir           = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_name}/"
  layer              = "services"
  type               = "operators"
  application_branch = "main"
  appname            = "ibm-mas-${var.appid}"
  namespace          = "mas-${var.instanceid}-${var.appid}"
  layer_config       = var.gitops_config[local.layer]
  //values_file        = "values.yaml"
  installPlan        = var.installPlan
 
# set values content for subscription
  values_content = {
    subscriptions = {
        masapp = {
          name = local.appname
          instanceid = var.instanceid
          namespace = local.namespace
          subscription = {
            channel = var.channel
            installPlanApproval = local.installPlan
            source = var.catalog
            sourceNamespace = var.catalog_namespace
          }
        }
      }
    }

/*
# set values content for app instance
  values_content_inst = {
    subscriptions = {
        masapp = {
          name = local.appname
          namespace = local.namespace
          instanceid = var.instanceid
        }
      }
    }
    */
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

# Add values for charts
resource "null_resource" "deployAppVals" {
  depends_on = [module.pullsecret]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

# Deploy
resource gitops_module masapp {
  depends_on = [null_resource.deployAppVals]

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

/*
# Add values for MAS App operator
resource "null_resource" "deployMASsub" {
  depends_on = [module.pullsecret]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yamlSub.sh '${local.chart_nameSub}' '${local.yaml_dirSub}' '${local.values_file}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content_sub)
    }
  }
}

# Add values for MAS App instance
resource "null_resource" "deployMASinst" {
  depends_on = [module.pullsecret]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yamlInst.sh '${local.chart_nameInst}' '${local.yaml_dirInst}' '${local.values_file}' '${var.appid}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content_inst)
    }
  }
}
*/

/*
# Deploy MAS App operator
resource gitops_module subscription {
  depends_on = [null_resource.deployMASsub]

  name        = local.name
  namespace   = local.namespace
  content_dir = local.yaml_dirSub
  server_name = var.server_name
  layer       = local.layer
  type        = "operators"
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}


# Deploy MAS App instance
resource gitops_module instance {
  depends_on = [null_resource.deployMASinst,gitops_module.subscription]

  name        = local.name
  namespace   = local.namespace
  content_dir = local.yaml_dirInst
  server_name = var.server_name
  layer       = local.layer
  type        = "instances"
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
*/
