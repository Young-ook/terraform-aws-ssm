# Variables for providing to module fixture codes

### network
variable "region" {
  description = "The aws region to run fault injection experiment"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "The list of availability zones to apply fault injection experiment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc" {
  description = "The vpc id to which the target autoscaling group belongs"
  type        = string
}

variable "asg" {
  description = "Autoscaling group name of fault injection target"
  type        = string
}

variable "role" {
  description = "Role ARN of autoscaling group of fault injection target"
  type        = string
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
