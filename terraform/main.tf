# Main Terraform configuration file

provider "aws" {
  region = var.aws_region
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get specific subnet IDs
data "aws_subnet" "selected" {
  for_each = toset(slice(data.aws_subnets.default.ids, 0, 3))
  id       = each.value
}

# Store sensitive parameters in AWS Parameter Store
resource "aws_ssm_parameter" "mongo_uri" {
  name        = "/travelmemory/mongo_uri"
  description = "MongoDB Connection URI"
  type        = "SecureString"
  value       = "mongodb://${aws_instance.mongodb.private_ip}:27017/travelmemory"
}

resource "aws_ssm_parameter" "backend_url" {
  name        = "/travelmemory/backend_url"
  description = "Backend URL for frontend configuration"
  type        = "String"
  value       = "http://${aws_instance.backend.public_ip}:${var.backend_port}"
}