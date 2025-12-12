locals {
  common_tags = merge(
    {
      Project = var.project_name
      Managed = "terraform"
    },
    var.tags
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnet_azs = [data.aws_availability_zones.available.names[0]]
  public_cidrs = [
    "10.0.1.0/24"
  ]
  private_cidrs = [
    "10.0.2.0/24"
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"

  cidr = "10.0.0.0/16"
  azs  = local.subnet_azs

  public_subnets  = local.public_cidrs
  private_subnets = local.private_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "private"
  }

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.common_tags
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "public_host" {
  name        = "${var.project_name}-public-sg"
  description = "Allow SSH from a single IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from allowed IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-sg"
  })
}

resource "aws_security_group" "private_host" {
  name        = "${var.project_name}-private-sg"
  description = "Allow SSH only from the public host security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "SSH from public host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.public_host.id]
    cidr_blocks      = []
    ipv6_cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-sg"
  })
}

locals {
  public_user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              EOF

  private_user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              EOF
}

resource "aws_instance" "public_host" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.public_instance_type
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.public_host.id]
  key_name               = var.key_name
  user_data              = local.public_user_data

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-host"
  })
}

resource "aws_instance" "private_host" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.private_instance_type
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.private_host.id]
  key_name               = var.key_name
  user_data              = local.private_user_data
  associate_public_ip_address = false

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-host"
  })
}

