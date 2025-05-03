# Security groups configuration

# MongoDB Security Group
resource "aws_security_group" "mongodb_sg" {
  name        = "${var.app_name}-mongodb-sg"
  description = "Security group for MongoDB instance"
  vpc_id      = data.aws_vpc.default.id

  # Allow MongoDB access only from backend
  ingress {
    from_port       = var.mongodb_port
    to_port         = var.mongodb_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
    description     = "MongoDB access from backend"
  }

  # Allow SSH access for administration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to specific IPs in production
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.app_name}-mongodb-sg-${var.environment}"
    Environment = var.environment
  }
}

# Backend Security Group
resource "aws_security_group" "backend_sg" {
  name        = "${var.app_name}-backend-sg"
  description = "Security group for backend instance"
  vpc_id      = data.aws_vpc.default.id

  # Allow backend API access from frontend and public
  ingress {
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
    description     = "Backend access from frontend"
  }

  # Public access to backend API (optional, can be restricted)
  ingress {
    from_port   = var.backend_port
    to_port     = var.backend_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Public access to backend API"
  }

  # Allow SSH access for administration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to specific IPs in production
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.app_name}-backend-sg-${var.environment}"
    Environment = var.environment
  }
}

# Frontend Security Group
resource "aws_security_group" "frontend_sg" {
  name        = "${var.app_name}-frontend-sg"
  description = "Security group for frontend instance"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP access to frontend
  ingress {
    from_port   = var.frontend_port
    to_port     = var.frontend_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access to frontend"
  }

  # Allow SSH access for administration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to specific IPs in production
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.app_name}-frontend-sg-${var.environment}"
    Environment = var.environment
  }
}

# Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
  name        = "${var.app_name}-lb-sg"
  description = "Security group for load balancer"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP access to load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access to load balancer"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.app_name}-lb-sg-${var.environment}"
    Environment = var.environment
  }
}