resource "aws_lb" "bastion" {
  name               = "${var.base_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.default_tags, {
    Name = "${var.base_name}-nlb"
  })
}

resource "random_string" "nlb_suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "aws_lb_target_group" "bastion" {
  name                 = "${var.base_name}-tg-${random_string.nlb_suffix.result}"
  port                 = 2222
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  tags = merge(var.default_tags, {
    Name = "${var.base_name}-tg-${random_string.nlb_suffix.result}"
  })

  depends_on = [aws_lb.bastion]

  lifecycle {
    create_before_destroy = true
  }
}

# Redirect to https listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.bastion.id
  port              = 22
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.bastion.id
    type             = "forward"
  }
}
