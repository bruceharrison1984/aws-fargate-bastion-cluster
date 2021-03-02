resource "aws_ecs_service" "bastion" {
  name            = "${var.base_name}-bastion"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.bastion.id
  desired_count   = var.container_count
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.bastion.arn
    container_name   = "bastion"
    container_port   = 2222
  }

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = concat([aws_security_group.bastion.id], var.security_group_ids)
  }

  tags = merge(var.default_tags, {
    Name = "${var.base_name}-public-ecs"
  })

  lifecycle {
    ignore_changes = [task_definition] ## prevent from triggering on every apply
  }

  depends_on = [aws_cloudwatch_log_group.bastion]
}

resource "aws_cloudwatch_log_group" "bastion" {
  name = "/ecs/${var.base_name}-bastion-task"

  tags = merge(var.default_tags, {
    Name = "/ecs/${var.base_name}-bastion-task"
  })
}

resource "aws_ecs_task_definition" "bastion" {
  family                   = "${var.base_name}-bastion-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "bastion"
    image     = "linuxserver/openssh-server"
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 2222
      hostPort      = 2222
    }]
    environment = [
      {
        name  = "DOCKER_MODS"
        value = "linuxserver/mods:openssh-server-ssh-tunnel" ## enable ssh-tunneling to backend resources
      }
    ]
    secrets = [
      {
        name      = "PUBLIC_KEY" ## inject public key in to container
        valueFrom = var.public_key_secret_arn
      },
      {
        name      = "USER_NAME" ## inject bastion username in to container
        valueFrom = var.bastion_username
      },
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.bastion.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = "us-east-2"
      }
    }
  }])

  tags = merge(var.default_tags, {
    Name = "${var.base_name}-bastion-task"
  })
}
