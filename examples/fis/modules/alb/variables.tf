### network
variable "vpc" {
  description = "The vpc ID for loadbalancer"
  type        = string
  default     = null
}

variable "subnets" {
  description = "The list of subnet IDs to deploy loadbalancer"
  type        = list(string)
  default     = null
}

### target
variable "asg" {
  description = "Autoscaling group name for target group attachment"
  type        = string
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
