# AWS SSM Private Access with VPC Endpoints

## Overview
This repository contains Terraform code to configure private access to AWS services such as Amazon Elastic Kubernetes Service (EKS) and AWS Systems Manager (SSM) using VPC endpoints. By leveraging Interface VPC Endpoints, the setup ensures secure communication with AWS services through the Amazon private network, bypassing the public internet.

## Objective
The primary goal of this project is to enable access to AWS services, including EKS, privately through VPC endpoints. This ensures:
- Enhanced security by avoiding public internet exposure
- Reduced latency by keeping data transfer within AWS's internal network
- Compliance with strict data sovereignty and network policies

## Infrastructure Components

### VPC
- Creates a secure, scalable network infrastructure:
- - Private subnets for service resources
- - Public subnets for NAT Gateway requiring internet access
- - NAT Gateways to allow private subnet resources to access the internet if needed
- - Route tables to manage traffic between subnets and gateways

### Private Access to AWS Services
- Configures Interface VPC Endpoints for services including:
- - Amazon Elastic Kubernetes Service (EKS) for private cluster access
- - AWS Systems Manager (SSM), including:
- - - ssm for general Systems Manager operations
- - - ec2messages for communication between EC2 instances and SSM
- - - ssmmessages for Session Manager
- Enables private DNS resolution for AWS services, so service URLs resolve to private IPs

### IAM Role and Instance Profile
- Provisions an IAM role for EC2 instances to securely access AWS services like SSM and EKS
- Associates the IAM role with an instance profile for EC2 integration

#### Bastion Host Setup
- Deploys a bastion host in the private subnet for secure access to private resources
- Configures the bastion host with:
- - Facilitates secure access to private resources
- - Configured with an IAM instance profile for SSM and EKS access

### Security Groups
- Implements least-privilege access with:
- - Security groups for EC2 instances, VPC endpoints, and other resources
- - Rules to allow specific private communications while restricting unnecessary access

## Flexible Design
- Provides configurable input variables for:
- - VPC CIDR and subnets
- - Availability zones
- - AWS region and environment
- - Bastion host AMI and instance type

### Resource Naming Convention
- {project}-{environment}-{resource-type}-{sequence}
- Example: ssm-prod-endpoint-001

## Architecture Overview
The Terraform code sets up the following infrastructure:

### VPC:
- Private and public subnets spread across multiple availability zones
- NAT Gateway in public subnets for private subnet internet access
- Internet Gateway for public subnet internet access

### VPC Endpoints:
- Interface endpoints for EKS and SSM services

### EC2 Bastion Host:
- Configured to operate in a private subnet
- Accessible only through an SSH key or Systems Manager Session Manager

### IAM Role and Instance Profile:
- Grants secure access to EKS and SSM

## Repository Structure
```
ssm-private-access/
├── main.tf                 # Root module: orchestrates the setup using submodules
├── variables.tf            # Input variables for the root module
├── outputs.tf              # Outputs for the root module
├── provider.tf             # AWS provider configuration
├── modules/                # Reusable Terraform modules
│   ├── network/            # VPC and networking module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── ssm/                # SSM-specific configuration
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
'-- terraform.tfvars        # Sample input variables file
```

## Prerequisites
### Required Tools
- Terraform >= 1.10
- AWS CLI >= 2.0

### AWS Requirements
- An AWS account with permissions to:
- - Create VPCs, subnets, and endpoints
- - Manage IAM roles and policies
- - Deploy EC2 instances and configure SSM

## Deployment Guide
### Initial Setup
1. Clone repository
2. Configure AWS credentials
3. Update terraform.tfvars

### Deployment Steps
Initialize Terraform
```
terraform init
```
Validate Terraform configuration
```
terraform validate
```
Plan Terraform changes
```
terraform plan
```
Apply Terraform changes
```
terraform apply
```

### Access Resources
- EKS: Use the configured VPC endpoints to access EKS privately
- Bastion Host: SSH into the bastion host or use Systems Manager Session Manager for access

### SSM Access/Debug Commands

# Access EC2 Instance
```
aws ssm start-session --target <instance-id>
```

# Verify endpoints  
```
aws ec2 describe-vpc-endpoints --vpc-endpoint-ids <endpoint-id>
```

## Multiple Environments
In order to deploy this infrastructure in multiple environments without duplicating the code and while maintaining distinct Terraform state files, I'd recommend using Terraform Workspaces
1. **Create a new workspace:**
   ```bash
   terraform workspace new workspacenew
2. **Switch to the new workspace:**
   ```bash
   terraform workspace select workspacenew 
3. **List workspaces:**
   ```bash
   terraform workspace list 
4. **Delete a workspace:**
   ```bash
   terraform workspace select default 
   terraform workspace delete workspacenew 

## Notes
- Ensure you have necessary permissions in your AWS account to create these resources
- Always review the Terraform plan before applying to understand the changes that will be made to your infrastructure
- Ensure you have set up billing alerts in your AWS account to avoid unexpected charges