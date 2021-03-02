resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.base_name}-bastion-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(var.default_tags, {
    Name = "${var.base_name}-bastion-execution-role"
  })
}

## allow ECS to write to Cloudwatch
resource "aws_iam_role_policy" "ecs_logs_policy" {
  name = "${var.base_name}-bastion-logs-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment_for_secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets.arn
}

resource "aws_iam_policy" "secrets" {
  name        = "${var.base_name}-bastion-task-policy-secrets"
  description = "Policy that allows access to the SSH public key secret"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AccessSecrets",
        Effect : "Allow",
        Action : ["secretsmanager:GetSecretValue"],
        Resource : [var.public_key_secret_arn, var.bastion_username]
      }
    ]
  })
}
