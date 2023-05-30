# Create SG for ECS Task
resource "aws_security_group" "ecsTaskSG" {
  name   = "${var.env}-ecsTaskSG"
  vpc_id = var.vpcID
 
  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_cluster" "ecsCluster" {
  name = "${var.env}-ecsCluster"

  tags = {
    Name = "${var.env} ECS Cluster"
    Env  = "${var.env}"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecsClusterCapacityProvider" {
  cluster_name = aws_ecs_cluster.ecsCluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Execution Role for tasks
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "${var.env}-ecsTaskExecutionRole"

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
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRolePolicyAttachment" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.env}-taskLog"

  tags = {
    Name = "${var.env} ECS Task Log"
    Env  = "${var.env}"
  }
}


# ECS Task Definition
resource "aws_ecs_task_definition" "ecsNginxTask" {
  family                   = "Linux"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = jsonencode([{
    name      = "${var.env}-nginxContainer"
    image     = var.imageURI
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.containerPort
      hostPort      = var.containerPort
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = "ap-southeast-1"
      }
    }
  }])
}

# ECS Service
resource "aws_ecs_service" "ecsService" {
  name                               = "${var.env}-ecsService"
  cluster                            = aws_ecs_cluster.ecsCluster.id
  task_definition                    = aws_ecs_task_definition.ecsNginxTask.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecsTaskSG.id]
    subnets          = var.subnets.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.albTargetGroup1ARN
    container_name   = "${var.env}-nginxContainer"
    container_port   = var.containerPort
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}