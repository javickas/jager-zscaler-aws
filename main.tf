# main.tf

# --- VPC 1 Module ---
module "vpc_1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.0"

  name = "${var.project_name}-VPC-1"
  cidr = var.vpc1_cidr

  azs              = var.azs
  private_subnets  = [cidrsubnet(var.vpc1_cidr, 8, 10), cidrsubnet(var.vpc1_cidr, 8, 11)]
  public_subnets   = [cidrsubnet(var.vpc1_cidr, 8, 20), cidrsubnet(var.vpc1_cidr, 8, 21)]
  database_subnets = [cidrsubnet(var.vpc1_cidr, 8, 30), cidrsubnet(var.vpc1_cidr, 8, 31)]

  enable_nat_gateway = true
  single_nat_gateway = !var.enable_nat_gateway_per_az
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}
####PLACE HOLDER FOR GWLB
# --- Gateway Load Balancer 1 for VPC 1 ---

# Security Group for the GLB interfaces
resource "aws_security_group" "glb1_sg" {
  name        = "${var.project_name}-GLB1-SG"
  description = "Allow GENEVE traffic for GLB1"
  vpc_id      = module.vpc_1.vpc_id

  # Ingress: Allow GENEVE from anywhere in the VPC (or specific GLB Endpoint IPs/CIDRs)
  # For now, allowing from VPC CIDR for flexibility. In production, restrict to Endpoint ENIs.
  ingress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = [module.vpc_1.vpc_cidr_block]
    description = "Allow GENEVE ingress from VPC for GLB endpoints"
  }

  # Egress: Allow GENEVE to anywhere in the VPC (or specific GLB Endpoint IPs/CIDRs)
  egress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = [module.vpc_1.vpc_cidr_block]
    description = "Allow GENEVE egress to VPC for GLB endpoints"
  }
  
  tags = merge(var.tags, { Name = "${var.project_name}-GLB1-SG" })
}

resource "aws_lb" "glb1" {
  name               = "${var.project_name}-GLB1"
  load_balancer_type = "gateway"
  subnets            = module.vpc_1.public_subnets # Place GLB in public subnets
  #security_groups    = [aws_security_group.glb1_sg.id]

  tags = merge(var.tags, { Name = "${var.project_name}-GLB1" })
}

# Target Group for GLB 1 (will be empty, awaiting virtual appliances)
resource "aws_lb_target_group" "glb1_tg" {
  name                 = "${var.project_name}-GLB1-TG"
  port                 = 6081 # GENEVE protocol default port
  protocol             = "GENEVE"
  vpc_id               = module.vpc_1.vpc_id
  target_type          = "ip" # Appliances often use IP addresses

  health_check {
    protocol            = "TCP" # Health check protocol for the actual appliance
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(var.tags, { Name = "${var.project_name}-GLB1-TG" })
}

# Listener for GLB 1
resource "aws_lb_listener" "glb1_listener" {
  load_balancer_arn = aws_lb.glb1.arn
  #port              = 6081 # GENEVE protocol default port
  #protocol          = "GENEVE"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.glb1_tg.arn
  }
}

# VPC Endpoint Service for GLB 1 (makes GLB available to other VPCs/endpoints)
resource "aws_vpc_endpoint_service" "glb1_endpoint_service" {
  acceptance_required        = false # Set to true for explicit acceptance in prod
  gateway_load_balancer_arns = [aws_lb.glb1.arn]

  tags = merge(var.tags, { Name = "${var.project_name}-GLB1-EndpointService" })
}

# --- VPC 2 Module ---
module "vpc_2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.0"

  name = "${var.project_name}-VPC-2"
  cidr = var.vpc2_cidr

  azs              = var.azs
  private_subnets  = [cidrsubnet(var.vpc2_cidr, 8, 10), cidrsubnet(var.vpc2_cidr, 8, 11)]
  public_subnets   = [cidrsubnet(var.vpc2_cidr, 8, 20), cidrsubnet(var.vpc2_cidr, 8, 21)]
  database_subnets = [cidrsubnet(var.vpc2_cidr, 8, 30), cidrsubnet(var.vpc2_cidr, 8, 31)]

  enable_nat_gateway = true
  single_nat_gateway = !var.enable_nat_gateway_per_az
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

####PLACE HOLDER FOR GWLB
# --- Gateway Load Balancer 2 for VPC 2 ---

# Security Group for the GLB interfaces
resource "aws_security_group" "glb2_sg" {
  name        = "${var.project_name}-GLB2-SG"
  description = "Allow GENEVE traffic for GLB2"
  vpc_id      = module.vpc_2.vpc_id

  ingress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = [module.vpc_2.vpc_cidr_block]
    description = "Allow GENEVE ingress from VPC for GLB endpoints"
  }

  egress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = [module.vpc_2.vpc_cidr_block]
    description = "Allow GENEVE egress to VPC for GLB endpoints"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-GLB2-SG" })
}

# Gateway Load Balancer
resource "aws_lb" "glb2" {
  name               = "${var.project_name}-GLB2"
  load_balancer_type = "gateway"
  subnets            = module.vpc_2.public_subnets
  #security_groups    = [aws_security_group.glb2_sg.id]

  tags = merge(var.tags, { Name = "${var.project_name}-GLB2" })
}

# Target Group for GLB 2 (will be empty, awaiting virtual appliances)
resource "aws_lb_target_group" "glb2_tg" {
  name                 = "${var.project_name}-GLB2-TG"
  port                 = 6081
  protocol             = "GENEVE"
  vpc_id               = module.vpc_2.vpc_id
  target_type          = "ip"

  health_check {
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(var.tags, { Name = "${var.project_name}-GLB2-TG" })
}

# Listener for GLB 2
resource "aws_lb_listener" "glb2_listener" {
  load_balancer_arn = aws_lb.glb2.arn
  #port              = 6081
  #protocol          = "GENEVE"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.glb2_tg.arn
  }
}

# VPC Endpoint Service for GLB 2
resource "aws_vpc_endpoint_service" "glb2_endpoint_service" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.glb2.arn]

  tags = merge(var.tags, { Name = "${var.project_name}-GLB2-EndpointService" })
}

# --- Transit Gateway ---
resource "aws_ec2_transit_gateway" "main" {
  description                     = "${var.project_name}-TransitGateway"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(var.tags, { Name = "${var.project_name}-TGW" })
}

# --- VPC 1 Transit Gateway Attachment ---
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = module.vpc_1.vpc_id
  subnet_ids         = [module.vpc_1.private_subnets[0]] 
  
  dns_support = "enable" 

  tags = merge(var.tags, { Name = "${var.project_name}-VPC1-TGW-Attachment" })
}

# # --- VPC 2 Transit Gateway Attachment ---

# --- Accept the TGW attachments ---
# resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "vpc1_accepter" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc1_attachment.id
# }

# resource "aws_ec2_transit_gateway_vpc_attachment_accepter" "vpc2_accepter" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc2_attachment.id
# }


### RUN TERRAFORM WITH THIS COMMENTED OUT###
### UNCOMMENT RERUN FOR UPDATE ####
##--- VPC 1 Route Table Update for TGW ---
# resource "aws_route" "vpc1_to_vpc2_tgw_route" {
#   # FIX 3: Use compact and flatten to ensure a known-at-plan-time set of IDs
#   for_each               = toset(compact(flatten([
#                            module.vpc_1.private_route_table_ids,
#                            module.vpc_1.database_route_table_ids
#                          ])))
#   route_table_id         = each.value
#   destination_cidr_block = var.vpc2_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.main.id
#   #depends_on             = [aws_ec2_transit_gateway_vpc_attachment_accepter.vpc1_accepter]
# }

# --- VPC 2 Route Table Update for TGW ---
# resource "aws_route" "vpc2_to_vpc1_tgw_route" {
#   # FIX 3: Use compact and flatten to ensure a known-at-plan-time set of IDs
#   for_each               = toset(compact(flatten([
#                            module.vpc_2.private_route_table_ids,
#                            module.vpc_2.database_route_table_ids
#                          ])))
#   route_table_id         = each.value
#   destination_cidr_block = var.vpc1_cidr
#   transit_gateway_id     = aws_ec2_transit_gateway.main.id
#   #depends_on             = [aws_ec2_transit_gateway_vpc_attachment_accepter.vpc2_accepter]
# }