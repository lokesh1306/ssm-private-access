variable "profile" {
  type        = string
  description = "Account in which the resources will be deployed"
}

variable "region" {
  type        = string
  description = "Region where the resources will be deployed"
}

variable "env" {
  type        = string
  description = "Environment where resources will be deployed"
}

variable "project_name" {
  type        = string
  description = "Init"
}

variable "additional_tags" {
  description = "Additional tags to merge with common tags"
  type        = map(string)
  default     = {}
}


// Network module variables
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnets for VPC"
}


variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnets for VPC"
}

variable "azs" {
  type        = list(string)
  description = "AZs to be used"
}

// SSM Module
variable "bastion_ami_id" {
  type        = string
  description = "AMI ID of the Bastion Host"
}

variable "bastion_instance_type" {
  type        = string
  description = "Bastion Host Instance Type"
}
