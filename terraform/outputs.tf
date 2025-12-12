output "vpc_id" {
  description = "ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = module.vpc.public_subnets[0]
}

output "private_subnet_id" {
  description = "ID of the private subnet."
  value       = module.vpc.private_subnets[0]
}

output "public_host_public_ip" {
  description = "Public IPv4 address of the bastion host."
  value       = aws_instance.public_host.public_ip
}

output "private_host_private_ip" {
  description = "Private IPv4 address of the internal host."
  value       = aws_instance.private_host.private_ip
}

