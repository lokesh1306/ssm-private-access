variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "private_subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "bastion_ami_id" {
  type        = string
  description = "AMI ID of the Bastion Host"
}

variable "bastion_instance_type" {
  type        = string
  description = "Bastion Host Instance Type"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block"
}