resource "aws_secretsmanager_secret" "map_secret" {
  for_each = var.secret_map

  name                    = "/${terraform.workspace}/${each.key}"
  recovery_window_in_days = var.secret_retention_days

  tags = merge(var.default_tags, {
    Name = "${var.name}-${each.key}"
  })
}

resource "aws_secretsmanager_secret_version" "map_secret" {
  for_each = aws_secretsmanager_secret.map_secret

  secret_id     = aws_secretsmanager_secret.map_secret[each.key].id
  secret_string = var.secret_map[each.key]
}
