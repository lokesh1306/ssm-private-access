output "ec2_sg" {
  value = aws_security_group.ec2_sg
}

output "ssm_role_name" {
  value = aws_iam_role.ssm_role.name
}

output "ssm_role_arn" {
  value = aws_iam_role.ssm_role.arn
}