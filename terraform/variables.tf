# Variables for the Terraform configuration

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
  default     = "travelmemory-key"
}

variable "frontend_port" {
  description = "Port for the frontend application"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "Port for the backend application"
  type        = number
  default     = 3001
}

variable "mongodb_port" {
  description = "Port for MongoDB"
  type        = number
  default     = 27017
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "travelmemory"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (adjust as needed)
}