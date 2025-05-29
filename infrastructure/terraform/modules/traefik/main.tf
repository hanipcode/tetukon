# Security Group for Traefik (receives traffic from ALB)
resource "aws_security_group" "traefik" {
  name_prefix = "${var.project_name}-${var.environment}-traefik-"
  vpc_id      = var.vpc_id

  # HTTP from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Traefik Dashboard (internal access)
  ingress {
    description = "Traefik Dashboard"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Only internal access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-traefik-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for Backend Services
resource "aws_security_group" "services" {
  name_prefix = "${var.project_name}-${var.environment}-services-"
  vpc_id      = var.vpc_id

  # Allow traffic from Traefik
  ingress {
    description     = "HTTP from Traefik"
    from_port       = 3001
    to_port         = 3003
    protocol        = "tcp"
    security_groups = [aws_security_group.traefik.id]
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