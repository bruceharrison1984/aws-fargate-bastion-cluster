output "bastion_ssh_endpoint" {
  value = module.bastion.endpoint
}

output "secret_arns" {
  value = module.secrets.secret_arns
}
