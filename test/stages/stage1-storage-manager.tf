module "storage_manager" {
  source = "github.com/cloud-native-toolkit/terraform-util-storage-class-manager.git"

  rwx_storage_class = ""
  rwo_storage_class = ""
  file_storage_class = ""
  block_storage_class = "ibmc-vpc-block-10iops-tier"
}
