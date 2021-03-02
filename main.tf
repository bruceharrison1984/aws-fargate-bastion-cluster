module "vpc" {
  source       = "./vpc"
  name         = local.base_name
  default_tags = local.default_tags

  cidr                        = local.settings["AWS__VPC__Cidr"]
  private_subnets             = local.settings["AWS__VPC__Private_Subnets"]
  public_subnets              = local.settings["AWS__VPC__Public_Subnets"]
  availability_zones          = local.settings["AWS__VPC__Availability_Zones"]
  vpc_flow_log_retention_days = 7
}

resource "aws_ecs_cluster" "main" {
  name = "${local.base_name}-cluster"

  tags = merge(local.default_tags, {
    Name = "${local.base_name}-cluster"
  })
}

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
}

resource "random_pet" "bastion_username" {
  length    = 2
  separator = "-"

  keepers = {
    "regen" = tls_private_key.bastion.public_key_pem
  }
}

module "secrets" {
  source       = "./secrets"
  name         = local.base_name
  default_tags = local.default_tags

  secret_map = {
    "shared/bastion/ssh/public_pem"         = tls_private_key.bastion.public_key_openssh
    "shared/bastion/ssh/private_pem"        = tls_private_key.bastion.private_key_pem
    "shared/bastion/ssh/username"           = random_pet.bastion_username.id
  }
}

module "bastion" {
  source       = "./bastion"
  base_name    = local.base_name
  default_tags = local.default_tags

  vpc_id                = module.vpc.id
  ecs_cluster_id        = aws_ecs_cluster.main.id
  public_subnet_ids     = module.vpc.public_subnets.*.id
  private_subnet_ids    = module.vpc.private_subnets.*.id
  public_key_secret_arn = module.secrets.secret_arn_map["shared/bastion/ssh/public_pem"].arn
  bastion_username      = module.secrets.secret_arn_map["shared/bastion/ssh/username"].arn
  security_group_ids    = []
  container_count = 3
}
