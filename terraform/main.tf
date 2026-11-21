# HELIOS VPC
resource "aws_vpc" "helios" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.helios.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "helios" {
  vpc_id = aws_vpc.helios.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.helios.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.helios.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# HELIOS Security Group
resource "aws_security_group" "helios" {
  name        = "${var.project_name}-sg"
  description = "Security group for HELIOS EC2 instance"
  vpc_id      = aws_vpc.helios.id

  ingress {
    description = "SSH from trusted IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HELIOS application from trusted IP"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}
# HELIOS SSH Key Pair
resource "aws_key_pair" "helios" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand("~/.ssh/helios-key.pub"))

  tags = {
    Name = "${var.project_name}-key"
  }
}
# Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# HELIOS EC2 Instance
resource "aws_instance" "helios" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.helios.id]
  key_name                    = aws_key_pair.helios.key_name
  iam_instance_profile        = aws_iam_instance_profile.helios.name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  depends_on = [aws_route_table_association.public]

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
# HELIOS EC2 IAM Role
resource "aws_iam_role" "helios_ec2" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# ECR Pull Permissions
resource "aws_iam_role_policy" "ecr_pull" {
  name = "${var.project_name}-ecr-pull"
  role = aws_iam_role.helios_ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.project_name}"
      }
    ]
  })
}

# HELIOS EC2 Instance Profile
resource "aws_iam_instance_profile" "helios" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.helios_ec2.name

  tags = {
    Name = "${var.project_name}-instance-profile"
  }
}
