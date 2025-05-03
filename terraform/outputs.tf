# Output values from the Terraform configuration

output "mongodb_private_ip" {
  description = "Private IP address of the MongoDB instance"
  value       = aws_instance.mongodb.private_ip
}

output "backend_public_ip" {
  description = "Public IP address of the backend instance"
  value       = aws_instance.backend.public_ip
}

output "backend_private_ip" {
  description = "Private IP address of the backend instance"
  value       = aws_instance.backend.private_ip
}

output "frontend_public_ip" {
  description = "Public IP address of the frontend instance"
  value       = aws_instance.frontend.public_ip
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.frontend.dns_name
}

output "backend_url" {
  description = "URL for the backend API"
  value       = "http://${aws_instance.backend.public_ip}:${var.backend_port}"
}

output "frontend_url" {
  description = "URL for the frontend application via load balancer"
  value       = "http://${aws_lb.frontend.dns_name}"
}

output "frontend_direct_url" {
  description = "Direct URL for the frontend application"
  value       = "http://${aws_instance.frontend.public_ip}:${var.frontend_port}"
}