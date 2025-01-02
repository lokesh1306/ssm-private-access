data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "tls_private_key" "ssm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ssm"
  public_key = tls_private_key.ssm.public_key_openssh
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg-${var.common_tags["Environment"]}"
  description = "Security group for EC2"
  vpc_id      = var.vpc_id

  tags = (
    var.common_tags
  )
}

resource "aws_security_group" "ssm_sg" {
  name        = "ssm-sg-${var.common_tags["Environment"]}"
  description = "Security group for SSM VPC endpoints"
  vpc_id      = var.vpc_id
  tags = (
    var.common_tags
  )
}

resource "aws_security_group_rule" "ec2_egress_ssm" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.ssm_sg.id
  depends_on               = [aws_security_group.ec2_sg, aws_security_group.ssm_sg]
}

resource "aws_security_group_rule" "ec2_egress_internet_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  depends_on        = [aws_security_group.ec2_sg, aws_security_group.ssm_sg]
}

resource "aws_security_group_rule" "ec2_egress_internet_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  depends_on        = [aws_security_group.ec2_sg, aws_security_group.ssm_sg]
}

resource "aws_security_group_rule" "ssm_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.ssm_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
  depends_on               = [aws_security_group_rule.ec2_egress_ssm]
}

resource "aws_security_group_rule" "ssm_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.ssm_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
  depends_on               = [aws_security_group_rule.ec2_egress_ssm]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  private_dns_enabled = true

  security_group_ids = [aws_security_group.ssm_sg.id]
  tags = merge(
    {
      Name = "ssm-endpoint-${var.common_tags["Environment"]}"
    },
    var.common_tags
  )
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.ssm_sg.id]
  private_dns_enabled = true
  tags = merge(
    {
      Name = "ec2-messages-endpoint-${var.common_tags["Environment"]}"
    },
    var.common_tags
  )
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = var.private_subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.ssm_sg.id]
  tags = merge(
    {
      Name = "ssm-messages-endpoint-${var.common_tags["Environment"]}"
    },
    var.common_tags
  )
}

resource "aws_iam_role" "ssm_role" {
  name               = "EC2-SSM-Access-Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "access_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile-${var.common_tags["Environment"]}"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami_id
  instance_type          = var.bastion_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  subnet_id              = element(var.private_subnet_ids, 0)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.ec2_key_pair.key_name
  user_data              = <<-EOF
    #!/bin/bash
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    elif [ "$ARCH" = "aarch64" ]; then
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
    else
      echo "Unsupported architecture: $ARCH" >&2
      exit 1
    fi

    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
    sudo chmod 700 get_helm.sh
    sudo sh get_helm.sh

    sudo yum install mariadb105 -y
  EOF
  tags = merge(
    {
      Name = "ec2-bastion-${var.common_tags["Environment"]}"
    },
    var.common_tags
  )
  provisioner "local-exec" {
    command     = <<EOT
      echo '${tls_private_key.ssm.private_key_pem}' > ~/.ssh/ssm-key.pem
      chmod 600 ~/.ssh/ssm-key.pem
    EOT
    interpreter = ["bash", "-c"]
  }
  depends_on = [aws_vpc_endpoint.ec2_messages, aws_vpc_endpoint.ssm, aws_vpc_endpoint.ssm_messages]
}
