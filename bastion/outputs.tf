output "endpoint" {
  value = "https://${aws_lb.bastion.dns_name}"
}
