
output "name" {
  description = "The name of the module"
  value       = local.name
  depends_on  = [gitops_module.mas_manage]
}

output "branch" {
  description = "The branch where the module config has been placed"
  value       = local.application_branch
  depends_on  = [gitops_module.mas_manage]
}

output "namespace" {
  description = "The namespace where the module will be deployed"
  value       = var.core_namespace
  depends_on  = [gitops_module.mas_manage]
}

output "server_name" {
  description = "The server where the module will be deployed"
  value       = var.server_name
  depends_on  = [gitops_module.mas_manage]
}

output "layer" {
  description = "The layer where the module is deployed"
  value       = local.layer
  depends_on  = [gitops_module.mas_manage]
}

output "type" {
  description = "The type of module where the module is deployed"
  value       = local.type
  depends_on  = [gitops_module.mas_manage]
}

output "mas_workspace_id" {
  description = "The id of the mas app workspace deployed"
  value       = var.mas_workspace_id
  depends_on  = [gitops_module.mas_manage]
}

output "mas_instance_id" {
  description = "The id of the mas instance deployed"
  value       = var.mas_instance_id
  depends_on  = [gitops_module.mas_manage]
}

