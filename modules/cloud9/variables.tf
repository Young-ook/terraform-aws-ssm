### network
variable "subnet" {
  description = "The subnet ID to deploy your cloud9 environment"
  type        = string
  default     = null
}

### workspace
variable "workspace" {
  description = "Cloud9 workspace configuration"
  default     = {}
}

### description
variable "name" {
  description = "Resource name of your cloud id environment"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
