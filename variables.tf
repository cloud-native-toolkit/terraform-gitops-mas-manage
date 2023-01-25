
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
  sensitive   = true
}

variable "kubeseal_cert" {
  type        = string
  description = "The certificate/public key used to encrypt the sealed secrets"
  default     = ""
}

variable "server_name" {
  type        = string
  description = "The name of the server"
  default     = "default"
}

variable "core_namespace" {
  type        = string
  description = "The namespace where MAS Core has been installed"
}

variable "ibm_entitlement_secret" {
  type        = string
  description = "The name of the secret where the entitlement key has been stored"
}

variable "mas_instance_id" {
  type        = string
  description = "The id of the MAS instance created when core was installed"
}

variable "mas_workspace_id" {
  type        = string
  description = "The id of the MAS workspace created when core was installed"
}

variable "db2_meta_storage_class" {
  type        = string
  description = "The storage class used for DB2 metadata. Must be RWX storage."
}

variable "db2_data_storage_class" {
  type        = string
  description = "The storage class used for DB2 data. Can be RWO."
}

variable "demodata" {
  type        = bool
  description = "Flag indicating demo data should be provisioned in the database"
  default     = false
}

variable "db2_instance_name" {
  type        = string
  description = "The name of the db2 instance that will be provisioned"
  default     = "db2w-manage"
}

variable "mas_app_channel" {
  type        = string
  description = "The operator change from which manage will be installed"
  default     = "8.4.x"
}

variable "mas_config_scope" {
  type        = string
  description = "The config scope for the MAS database"
  default     = "wsapp"
}

variable "db2_dbname" {
  type        = string
  description = "The name of the db2 instance that will be provisioned"
  default     = "MANAGE"
}
