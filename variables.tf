
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

variable "channel" {
  type        = string
  description = "Subscription channel"
  default     = "8.x"
}

variable "installPlan" {
  type        = string
  description = "Install Plan for App"
  default     = "Automatic"
}

variable "catalog" {
  type        = string
  description = "App catalog source"
  default     = "ibm-operator-catalog"
}

variable "catalog_namespace" {
  type        = string
  description = "Catalog source namespace"
  default     = "openshift-marketplace"
}

variable "instanceid" {
  type        = string
  description = "instance name for MAS - for example: masdemo or mas8 "
}

variable "entitlement_key" {
  type        = string
  description = "IBM entitlement key for MAS"
}

variable "appid" {
  type        = string
  description = "MAS AppID to deploy.  Expects: manage"
  default     = "manage"
}

variable "workspace_id" {
  type = string
  description = "MAS workspace id"
  
}

variable "db_user" {
  type = string
  sensitive = true
  description = "database connection username"

}

variable "db_password" {
  type = string
  sensitive = true
  description = "database connection password"
  
}

variable "db_cert" {
  type = string
  sensitive = true
  description = "database connection public cert"
  
}

variable "db_url" {
  type = string
  sensitive = true
  description = "database connection url"
  
} 

variable "db_schema" {
  type = string
  description = "database schema name"
  
}

variable "db_secret" {
  type = string
  description = "database credentials secrets"
  
}

variable "db_schema" {
  type = string
  description = "database schema"
  default = "maximo"
  
}

variable "demodata" {
  type = bool
  description = "depoloy demo data for app"
  default = false
  
}

