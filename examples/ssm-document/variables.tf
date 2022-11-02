# Variables for providing to module fixture codes

### features
variable "features" {
  description = "Feature toggle options"
  type        = map(bool)
  default = {
    diskfull = true
    cwagent  = true
    envoy    = true
  }
}

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
  default     = "us-east-1"
}

### compute
variable "node_groups" {
  description = "Node groups definition"
  default     = []
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "ssm"
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
