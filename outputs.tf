output "vpc_cidr" {
  value = var.vpc_cidr
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "ec2_sg" {
  value = module.ssm.ec2_sg.id
}

output "ssm_role_name" {
  value = module.ssm.ssm_role_name
}

output "ssm_role_arn" {
  value = module.ssm.ssm_role_arn
}

output "route_table_id" {
  value = module.network.route_table_id
}