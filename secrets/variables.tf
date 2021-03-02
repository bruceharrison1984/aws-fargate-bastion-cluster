variable "name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "secret_map" {
  description = "A Key/Value map of secrets that will be added to AWS Secrets"
  type        = map(string)
}

variable "default_tags" {
  description = "Tags to be applied to resources"
}

variable "secret_retention_days" {
  default     = 0
  description = "Number of days before secret is actually deleted. Increasing this above 0 will result in Terraform errors if you redeploy to the same workspace."
}
