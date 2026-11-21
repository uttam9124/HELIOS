
variable "aws_region" {
  description = "AWS region for HELIOS infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile for deployment"
  type        = string
  default     = null
}

variable "aws_account_id" {
  description = "AWS account ID for ECR permissions"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS account ID must contain exactly 12 digits."
  }
}

variable "project_name" {
  description = "Name of the HELIOS project"
  type        = string
  default     = "helios"
}

variable "vpc_cidr" {
  description = "CIDR block for the HELIOS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for HELIOS"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "Trusted public IP CIDR allowed for SSH access"
  type        = string
}
