resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.default_tags, {
    Name = "${var.name}-vpc"
  })

  depends_on = [aws_cloudwatch_log_group.vpc_flow_log]
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(var.default_tags, {
    Name = "${var.name}-vpc-flow-log"
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name              = "${var.name}-vpc-flow-log"
  retention_in_days = var.vpc_flow_log_retention_days

  tags = merge(var.default_tags, {
    Name = "${var.name}-vpc-flow-log"
  })
}

