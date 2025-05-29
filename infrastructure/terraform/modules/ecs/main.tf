# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cluster"
  }
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Service Discovery Namespace
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.project_name}-${var.environment}.local"
  description = "Service discovery namespace for microservices"
  vpc         = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-service-discovery"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "services" {
  for_each = toset(concat(var.service_names, ["traefik"]))

  name              = "/ecs/${var.project_name}-${var.environment}/${each.value}"
  retention_in_days = 14

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.value}-logs"
    Service = each.value
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-task-execution-role"
  }
}

# Attach the ECS task execution role policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for Traefik Task (with ECS discovery permissions)
resource "aws_iam_role" "traefik_task_role" {
  name = "${var.project_name}-${var.environment}-traefik-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-traefik-task-role"
  }
}

# IAM Policy for Traefik ECS Service Discovery
resource "aws_iam_policy" "traefik_ecs_discovery" {
  name        = "${var.project_name}-${var.environment}-traefik-ecs-discovery"
  description = "Policy for Traefik to discover ECS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:ListServices",
          "ecs:DescribeServices",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeTaskDefinition",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-traefik-ecs-discovery"
  }
}

# Attach the ECS discovery policy to Traefik task role
resource "aws_iam_role_policy_attachment" "traefik_ecs_discovery_policy" {
  role       = aws_iam_role.traefik_task_role.name
  policy_arn = aws_iam_policy.traefik_ecs_discovery.arn
}

# Security Group for Backend Services
resource "aws_security_group" "services" {
  name_prefix = "${var.project_name}-${var.environment}-services-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from Traefik"
    from_port       = 3001
    to_port         = 3003
    protocol        = "tcp"
    security_groups = [var.traefik_security_group_id]
  }

  # Allow inter-service communication
  ingress {
    description = "Inter-service communication"
    from_port   = 3001
    to_port     = 3003
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-services-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Service Discovery Services for each microservice
resource "aws_service_discovery_service" "services" {
  for_each = var.service_ports

  name = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_grace_period_seconds = 30

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.key}-discovery"
    Service = each.key
  }
}

# Traefik Task Definition
resource "aws_ecs_task_definition" "traefik" {
  family                   = "${var.project_name}-${var.environment}-traefik"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.traefik_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "traefik"
      image = "${var.ecr_repository_urls["traefik"]}:latest"
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        },
        {
          containerPort = 8080
          protocol      = "tcp"
        },
        {
          containerPort = 8443
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "ECS_CLUSTER_NAME"
          value = aws_ecs_cluster.main.name
        }
      ]
      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget --no-verbose --tries=1 --spider http://localhost:8080/ping || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.services["traefik"].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      essential = true
    }
  ])

  tags = {
    Name    = "${var.project_name}-${var.environment}-traefik-task"
    Service = "traefik"
  }
}

# Backend Services Task Definitions
resource "aws_ecs_task_definition" "services" {
  for_each = var.service_ports

  family                   = "${var.project_name}-${var.environment}-${each.key}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = each.key
      image = "${var.ecr_repository_urls[each.key]}:latest"
      portMappings = [
        {
          containerPort = each.value
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "PORT"
          value = tostring(each.value)
        },
        {
          name  = "NODE_ENV"
          value = "production"
        }
      ]
      healthCheck = {
        command = [
          "CMD-SHELL",
          "node -e \"const http = require('http'); const options = { host: 'localhost', port: ${each.value}, path: '/health', timeout: 2000 }; const req = http.request(options, (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }); req.on('error', () => process.exit(1)); req.end();\""
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.services[each.key].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      essential = true
    }
  ])

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.key}-task"
    Service = each.key
  }
}

# Traefik ECS Service
resource "aws_ecs_service" "traefik" {
  name            = "${var.project_name}-${var.environment}-traefik"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.traefik.arn
  desired_count   = 2  # At least 2 for HA
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.traefik_security_group_id]
    subnets          = var.public_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.traefik_target_group_arn
    container_name   = "traefik"
    container_port   = 8000
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]

  tags = {
    Name    = "${var.project_name}-${var.environment}-traefik-service"
    Service = "traefik"
  }
}

# Backend ECS Services
resource "aws_ecs_service" "services" {
  for_each = var.service_ports

  name            = "${var.project_name}-${var.environment}-${each.key}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.services.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.services[each.key].arn
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.key}-service"
    Service = each.key
  }
}

# Auto Scaling Target for Backend Services
resource "aws_appautoscaling_target" "ecs_target" {
  for_each = var.service_ports

  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.services[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy for Backend Services
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  for_each = var.service_ports

  name               = "${var.project_name}-${var.environment}-${each.key}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
} 