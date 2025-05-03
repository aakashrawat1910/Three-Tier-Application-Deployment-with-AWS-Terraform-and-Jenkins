# EC2 instances and load balancer configuration

# MongoDB Instance
resource "aws_instance" "mongodb" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]

  tags = {
    Name        = "${var.app_name}-mongodb-${var.environment}"
    Environment = var.environment
  }

  user_data = file("${path.module}/scripts/mongodb_setup.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

# Backend Instance
resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  subnet_id              = tolist(data.aws_subnets.default.ids)[1]

  tags = {
    Name        = "${var.app_name}-backend-${var.environment}"
    Environment = var.environment
  }

  user_data = templatefile("${path.module}/scripts/backend_setup.sh", {
    mongodb_ip   = aws_instance.mongodb.private_ip
    backend_port = var.backend_port
  })

  depends_on = [aws_instance.mongodb]
}

# Frontend Instance
resource "aws_instance" "frontend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  subnet_id              = tolist(data.aws_subnets.default.ids)[2]

  tags = {
    Name        = "${var.app_name}-frontend-${var.environment}"
    Environment = var.environment
  }

  user_data = templatefile("${path.module}/scripts/frontend_setup.sh", {
    backend_url  = "http://${aws_instance.backend.private_ip}:${var.backend_port}"
    frontend_port = var.frontend_port
  })

  depends_on = [aws_instance.backend]
}

# Optional: Load Balancer for Frontend
resource "aws_lb" "frontend" {
  name               = "${var.app_name}-frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name        = "${var.app_name}-frontend-lb-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.app_name}-frontend-tg"
  port     = var.frontend_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    port                = var.frontend_port
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend.id
  port             = var.frontend_port
}