#  Maximo Application Suite - MAS Application Gitops terraform module
![Verify and release module](https://github.com/cloud-native-toolkit/terraform-gitops-mas-manage/workflows/Verify%20and%20release%20module/badge.svg)

Deploys the MAS applications as part of Maximo Application Suite via gitops.  To run, download the BOM (Bill of Materials) from the module catalog and build the terraform from there.  Specify the MAS-Core instance id - in the `instanceid` variable.  This will create a namespace of the name "mas-(instanceid)-(appid)".

Note if your cluster is not setup for gitops, download the gitops bootstrap BOM from the module catalog first to setup the gitops tooling.

## Supported platforms

- OCP 4.6+

## Suggested companion modules

The module itself requires some information from the cluster and needs a
namespace to be created. The following companion
modules can help provide the required information:

- Gitops:  github.com/cloud-native-toolkit/terraform-tools-gitops
- Gitops Bootstrap: github.com/cloud-native-toolkit/terraform-util-gitops-bootstrap
- Namespace:  github.com/ibm-garage-cloud/terraform-cluster-namespace
- Pull Secret:  github.com/cloud-native-toolkit/terraform-gitops-pull-secret
- Catalog: github.com/cloud-native-toolkit/terraform-gitops-cp-catalogs 
- Cert:  github.com/cloud-native-toolkit/terraform-util-sealed-secret-cert
- Cluster: github.com/cloud-native-toolkit/terraform-ocp-login
- CertManager: github.com/cloud-native-toolkit/terraform-gitops-ocp-cert-manager

## Example usage

```hcl-terraform
module "mas_manage" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-mas-manage"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  server_name = module.gitops.server_name
  kubeseal_cert = module.gitops.sealed_secrets_cert
  entitlement_key = module.catalog.entitlement_key
  instanceid = "mas8"
  appid = "manage"

}
```
