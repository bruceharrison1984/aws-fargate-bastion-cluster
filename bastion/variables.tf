variable "base_name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "default_tags" {
  description = "Tags to be applied to resources"
}

variable "vpc_id" {
  description = "Id of the VPC to create the security group"
}

variable "ecs_cluster_id" {
  description = "Id of the ECS cluster to create the bastion containers in"
}

variable "public_subnet_ids" {
  description = "Public subnets where the ALB should be deployed"
}

variable "private_subnet_ids" {
  description = "IDs of private subnets where the bastion containers should be deployed"
}

variable "public_key_secret_arn" {
  description = "The ARN of the Secret that contains the SSH public key"
}

variable "bastion_username" {
  description = "The ARN of the Secret that contains the bastion username"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups to allow the bastion server access to resources"
}

variable "container_count" {
  description = "The number of bastion host containers to run"
}