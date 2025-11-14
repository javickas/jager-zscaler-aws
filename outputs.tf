# outputs.tf
output "vpc1_id" {
  description = "The ID of the first VPC"
  value       = module.vpc_1.vpc_id
}

output "vpc1_public_subnets" {
  description = "IDs of the public subnets in VPC 1"
  value       = module.vpc_1.public_subnets
}

output "vpc1_private_subnets" {
  description = "IDs of the private subnets in VPC 1"
  value       = module.vpc_1.private_subnets
}

# output "vpc1_alb_dns_name" {
#   description = "The DNS name of the Application Load Balancer in VPC 1"
#   value       = module.alb_vpc_1.lb_dns_name
# }

output "vpc2_id" {
  description = "The ID of the second VPC"
  value       = module.vpc_2.vpc_id
}

output "vpc2_public_subnets" {
  description = "IDs of the public subnets in VPC 2"
  value       = module.vpc_2.public_subnets
}

output "vpc2_private_subnets" {
  description = "IDs of the private subnets in VPC 2"
  value       = module.vpc_2.private_subnets
}

# output "vpc2_alb_dns_name" {
#   description = "The DNS name of the Application Load Balancer in VPC 2"
#   value       = module.alb_vpc_2.lb_dns_name
# }

output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_default_route_table_id" {
  description = "The ID of the Transit Gateway's default route table"
  value       = aws_ec2_transit_gateway.main.association_default_route_table_id
}
output "vpc1_bastion_public_ips" {
  description = "Public IPs of bastion hosts in VPC 1"
  value       = [for instance in module.vpc1_bastion_instances : instance.public_ip]
}

output "vpc1_private_instance_ids" {
  description = "IDs of private instances in VPC 1"
  value       = [for instance in module.vpc1_private_instances : instance.id]
}

output "vpc2_bastion_public_ips" {
  description = "Public IPs of bastion hosts in VPC 2"
  value       = [for instance in module.vpc2_bastion_instances : instance.public_ip]
}

output "vpc2_private_instance_ids" {
  description = "IDs of private instances in VPC 2"
  value       = [for instance in module.vpc2_private_instances : instance.id]
}