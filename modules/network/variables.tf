variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnets for VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnets for VPC"
}

variable "azs" {
  type        = list(string)
  description = "AZs to be used"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}