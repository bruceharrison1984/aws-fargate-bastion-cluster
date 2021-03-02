variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "availability_zones" {
  description = "List of availability zones"
}

variable "default_tags" {
  description = "Tags to be applied to resources"
}

variable "vpc_flow_log_retention_days" {
  description = "Tags to be applied to resources"
}
