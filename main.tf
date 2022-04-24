locals {
  name          = "mas-appdeploy"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  inst_dir      = "${local.yaml_dir}/instance"
  
  chart_nameSub     ="ibm-masapp-operator-subscription"
  chart_nameInst    ="ibm-masapp-operator-instance"
  yaml_dirSub       = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_nameSub}/"
  yaml_dirInst      = "${path.cwd}/.tmp/${local.name}/chart/${local.chart_nameInst}/"

  layer = "services"
  type  = "base"
  application_branch = "main"
  appname = "ibm-mas-${var.appid}"
  namespace = "mas-${var.instanceid}-${var.appid}"
  layer_config = var.gitops_config[local.layer]
  values_file = "values.yaml"
  installPlan = var.installPlan

  values_content = {
    subscriptions = {
        masapp = {
          name = local.appname
          subscription = {
            channel = var.channel
            installPlanApproval = local.installPlan
            name = var.appid
            source = var.catalog
            sourceNamespace = var.catalog_namespace
          }
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

# Install MAS App operator
resource "null_resource" "deployMASsub" {
  depends_on = [module.pullsecret]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yamlSub.sh '${local.chart_nameSub}' '${local.yaml_dirSub}' '${local.values_file}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
      BIN_DIR = local.bin_dir
    }
  }
}

# Deploy MAS App operator
resource gitops_module subscription {
  depends_on = [null_resource.deployMASsub]

  name        = local.chart_nameSub
  namespace   = local.namespace
  content_dir = local.yaml_dirSub
  server_name = var.server_name
  layer       = local.layer
  type        = "operators"
  branch      = local.application_branch
  config      = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}



/*
# Deploy MAS-Manage operator
resource null_resource setup_gitops_op {
  depends_on = [null_resource.deployMANop]

  triggers = {
    name = local.name
    namespace = local.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    type = local.type
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --type '${self.triggers.type}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
} */
