### network
variable "subnets" {
  description = "The list of subnet IDs to deploy your EKS cluster"
  type        = list(string)
  default     = null
}

variable "node_groups" {
  description = "Node groups definition"
  default     = []
}

### security
variable "policy_arns" {
  description = "A list of policy ARNs to attach the node groups role"
  type        = list(string)
  default     = []
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
