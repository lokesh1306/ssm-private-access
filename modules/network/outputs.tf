output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "route_table_id" {
  value = aws_route_table.private_subnet_route_table[*].id
}