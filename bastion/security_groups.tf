## we have to perform a lookup to get the private IP addresses of the NLB so we can allow it to talk to the ECS containers

data "aws_network_interfaces" "lb" {
  filter {
    name   = "description"
    values = ["ELB net/${aws_lb.bastion.name}/*"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "attachment.status"
    values = ["attached"]
  }
}

locals {
  nlb_interface_ids = flatten([data.aws_network_interfaces.lb.ids])
  nlb_private_ips   = [for ip in data.aws_network_interface.lb.*.private_ip : "${ip}/32"]
}

data "aws_network_interface" "lb" {
  count = length(var.public_subnet_ids) ## NIs correspond with public subnets
  id    = local.nlb_interface_ids[count.index]
}

resource "aws_security_group" "bastion" {
  name   = "${var.base_name}-sg-bastion"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 2222
    to_port     = 2222
    cidr_blocks = local.nlb_private_ips
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, {
    Name = "${var.base_name}-sg-bastion"
  })
}

