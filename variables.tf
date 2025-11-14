# variables.tf 
#####Update the variables as needed####
variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # Or your preferred region like "us-east-2"
}

variable "project_name" {
  description = "A prefix for resource naming"
  type        = string
  default     = ""
}

variable "vpc1_cidr" {
  description = "CIDR block for the first VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc2_cidr" {
  description = "CIDR block for the second VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "azs" {
  description = "List of availability zones to use for subnets (must be 2)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] # Adjust for your chosen region
  validation {
    condition     = length(var.azs) == 2
    error_message = "Please provide exactly two availability zones."
  }
}

variable "enable_nat_gateway_per_az" {
  description = "Whether to deploy a NAT Gateway in each AZ (true) or a single one (false) per VPC"
  type        = bool
  default     = true # Setting to true for high availability
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Dev"
    Project     = ""
    Owner       = ""
  }
}

# variables.tf

# ... (existing variables) ...

variable "instance_type" {
  description = "EC2 instance type for the bastion and private instances"
  type        = string
  default     = "t3.micro" # Using a small instance type for demonstration
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances (Amazon Linux 2 usually)"
  type        = string
  default     = "ami-0cae6d6fe6048ca2c" # User provided AMI ID - THIS IS Amazon Linux in US-EAST1
}

variable "key_pair_name" {
  description = "The name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "" # You should customize this
}

variable "ssh_ingress_cidr" {
  description = "CIDR block for SSH access to bastion hosts. Be restrictive in production."
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: 0.0.0.0/0 allows SSH from anywhere. Restrict this in production.
}

variable "sec-pubvpc1" {
  description = "VPC1 Secgroup"
  type = string
  default = "sg-0f14f00040b342bee"
}

variable "sec-pubvpc2"{
  description = "VPC2 Secgroup"
  type = string
  default = "sg-0deed86818a84b015"
}

variable "sec-privpc1"{
  description = "VPC1 Secgroup"
  type = string
  default = "sg-0641f8649259b79b3"
}

variable "sec-privpc2" {
  description = "VPC2 Secgroup"
  type = string
  default = "sg-03accd521bfddbaf2"
  
}



## sg-0f14f00040b342bee public-vpc1

## sg-0deed86818a84b015 public-vpc2

## sg-03accd521bfddbaf2 pri-vpc2

## sg-0641f8649259b79b3 pri - vpc1