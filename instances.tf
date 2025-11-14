###### IF SGs exist###############
######exsisting security groups ########
# data "aws_security_group" "privpc1" {
#   id = var.sec-privpc1 # Or use id = "sg-xxxxxxxxxxxxxxxxx"
#   #vpc_id = "your-vpc-id" # Optional, but good practice if you have multiple VPCs
# }

# data "aws_security_group" "privpc2" {
#   id = var.sec-privpc2 # Or use id = "sg-xxxxxxxxxxxxxxxxx"
#   #vpc_id = "your-vpc-id" # Optional, but good practice if you have multiple VPCs
# }

# data "aws_security_group" "pubvpc1" {
#   id = var.sec-pubvpc1 # Or use id = "sg-xxxxxxxxxxxxxxxxx"
#   #vpc_id = "your-vpc-id" # Optional, but good practice if you have multiple VPCs
# }

# data "aws_security_group" "pubvpc2" {
#   id = var.sec-pubvpc2 # Or use id = "sg-xxxxxxxxxxxxxxxxx"
#   #vpc_id = "your-vpc-id" # Optional, but good practice if you have multiple VPCs
# }

#################################
# VPC 1 EC2 Instances
#################################
# Security Group for VPC 1 Bastion Hosts (Public access for SSH)
resource "aws_security_group" "vpc1_bastion_sg" {
  name        = "${var.project_name}-VPC1-Bastion-SG"
  description = "Allow SSH from specific CIDRs to VPC1 Bastion Hosts"
  vpc_id      = module.vpc_1.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress_cidr # Use variable for SSH access
    description = "SSH Access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-VPC1-Bastion-SG" })
}

# Security Group for VPC 1 Private Instances (SSH from Bastion, all internal VPC traffic)
resource "aws_security_group" "vpc1_private_sg" {
  name        = "${var.project_name}-VPC1-Private-SG"
  description = "Allow SSH from VPC1 Bastion and all internal traffic within VPC1"
  vpc_id      = module.vpc_1.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vpc1_bastion_sg.id] # Allow SSH from Bastion SG
    description     = "SSH from VPC1 Bastion"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc_1.vpc_cidr_block] # Allow all traffic within VPC1
    description = "Allow all internal VPC1 traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-VPC1-Private-SG" })
}

# VPC 1 Bastion Instances (one per public subnet)
module "vpc1_bastion_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1.4"

  for_each = { for i, az in var.azs : az => module.vpc_1.public_subnets[i] }

  name                        = "${var.project_name}-VPC1-Bastion" # e.g. -VPC1-Bastion-1a
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  #vpc_security_group_ids      = [data.aws_security_group.pubvpc1.id] #<use if exsiting SG>
   vpc_security_group_ids      = [aws_security_group.vpc1_bastion_sg.id]
  subnet_id                   = each.value
  

  associate_public_ip_address = true

  tags = merge(var.tags, { Name = "${var.project_name}-VPC1-Bastion" })
}

# VPC 1 Private Instances (one per private application subnet)
module "vpc1_private_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1.4"

   for_each = { for i, az in var.azs : az => module.vpc_1.private_subnets[i] }

  name                        = "${var.project_name}-VPC1-Private" # e.g. -VPC1-Private-1a
  
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
#   vpc_security_group_ids      = [data.aws_security_group.privpc1.id] #existing SG
  vpc_security_group_ids      = [aws_security_group.vpc1_private_sg.id]
  subnet_id                   = each.value
  associate_public_ip_address = false # Private instance, no public IP

  tags = merge(var.tags, { Name = "${var.project_name}-VPC1-Private" })
}
#################################
# VPC 2 EC2 Instances
#################################
# VPC 2 Bastion Instances (one per public subnet)
# Security Group for VPC 2 Bastion Hosts (Public access for SSH)

resource "aws_security_group" "vpc2_bastion_sg" {
  name        = "${var.project_name}-VPC2-Bastion-SG"
  description = "Allow SSH from specific CIDRs to VPC2 Bastion Hosts"
  vpc_id      = module.vpc_2.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress_cidr
    description = "SSH Access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-VPC2-Bastion-SG" })
}

# Security Group for VPC 2 Private Instances (SSH from Bastion, all internal VPC traffic)
resource "aws_security_group" "vpc2_private_sg" {
  name        = "${var.project_name}-VPC2-Private-SG"
  description = "Allow SSH from VPC2 Bastion and all internal traffic within VPC2" 
  vpc_id      = module.vpc_2.vpc_id

ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vpc2_bastion_sg.id] # Allow SSH from Bastion SG
    description     = "SSH from VPC2 Bastion"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc_2.vpc_cidr_block] # Allow all traffic within VPC2
    description = "Allow all internal VPC2 traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-VPC2-Private-SG" })
}

module "vpc2_bastion_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1.4"

  for_each = { for i, az in var.azs : az => module.vpc_2.public_subnets[i] }

  name                        = "${var.project_name}-VPC2" # e.g. -VPC2-Bastion-1a
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  #vpc_security_group_ids      = [data.aws_security_group.pubvpc2.id] #Existing SG
  vpc_security_group_ids      = [aws_security_group.vpc2_bastion_sg.id]
  subnet_id                   = each.value
  associate_public_ip_address = true

  tags = merge(var.tags, { Name = "${var.project_name}-VPC2-Bastion" })
  
}

# VPC 2 Private Instances (one per private application subnet)
module "vpc2_private_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1.4"

 for_each = { for i, az in var.azs : az => module.vpc_2.private_subnets[i] }

  name                        = "${var.project_name}-VPC2" # e.g. -VPC2-Private-1a
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
#   vpc_security_group_ids      = [data.aws_security_group.privpc2.id] #existing SG
vpc_security_group_ids      = [aws_security_group.vpc2_private_sg.id]
  subnet_id                   = each.value
  associate_public_ip_address = false # Private instance, no public IP

  tags = merge(var.tags, { Name = "${var.project_name}-VPC2-Private" })
}
