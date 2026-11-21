output "vpc_id" {
  description = "HELIOS VPC ID"
  value       = aws_vpc.helios.id
}

output "public_subnet_id" {
  description = "HELIOS Public Subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "HELIOS Security Group ID"
  value       = aws_security_group.helios.id
}

output "instance_id" {
  description = "HELIOS EC2 Instance ID"
  value       = aws_instance.helios.id
}

output "public_ip" {
  description = "HELIOS EC2 Public IP Address"
  value       = aws_instance.helios.public_ip
}

output "public_dns" {
  description = "HELIOS EC2 Public DNS"
  value       = aws_instance.helios.public_dns
}

output "ssh_command" {
  description = "Command to connect to HELIOS EC2"
  value       = "ssh -i ~/.ssh/helios-key ubuntu@${aws_instance.helios.public_ip}"
}

output "application_url" {
  description = "HELIOS Application URL"
  value       = "http://${aws_instance.helios.public_ip}:5000"
}
