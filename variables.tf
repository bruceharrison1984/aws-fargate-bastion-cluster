variable "aws_secret_key" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_session_token" {
  type = string
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}

locals {
  settings = yamldecode(file("${path.root}/.env/settings.yml"))
  default_tags = merge(var.additional_tags, {
    terraform = true
    workspace = terraform.workspace
    project   = local.settings["Project__Name"]
  })
  base_name = "${local.settings["Project__Name"]}-${terraform.workspace}"
}


