### network
variable "subnets" {
  description = "The list of subnet IDs to deploy your EC2 cluster"
  type        = list(string)
}

variable "node_groups" {
  description = "Node groups definition"
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
