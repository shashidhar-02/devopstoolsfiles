# =============================================================================
# ASG MODULE - Variables
# =============================================================================

variable "name_prefix" {
  description = "Name prefix for ASG resources"
  type        = string
}

variable "min_size" {
  description = "Minimum size"
  type        = number
}

variable "max_size" {
  description = "Maximum size"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity"
  type        = number
}

variable "vpc_zone_identifier" {
  description = "Subnet IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Target group ARNs"
  type        = list(string)
  default     = []
}

variable "launch_template" {
  description = "Launch template configuration"
  type = object({
    name          = string
    image_id      = string
    instance_type = string
  })
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
