# =============================================================================
# IAM MODULE - Variables
# =============================================================================

variable "name_prefix" {
  description = "Prefix for IAM resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    service  = string
    policies = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
