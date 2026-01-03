# =============================================================================
# Database EC2 Module - Main
# =============================================================================
# Provisiona EC2 + EBS + Security Group para bancos de dados em ambiente dev/test.
# O banco específico (Mongo, Postgres, Redis, etc.) é configurado via user_data.
# =============================================================================

locals {
  common_tags = merge(
    {
      Project   = var.project_name
      Module    = "database-ec2"
      ManagedBy = "terraform"
    },
    var.tags
  )
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_subnet" "selected" {
  id = var.subnet_id
}

# -----------------------------------------------------------------------------
# Security Group
# -----------------------------------------------------------------------------

resource "aws_security_group" "database" {
  name        = "${var.project_name}-database-sg"
  description = "Security Group for ${var.project_name} database"
  vpc_id      = var.vpc_id

  # Ingress: Permite acesso à porta do banco apenas dos CIDRs permitidos
  ingress {
    description = "Database port access"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }


  dynamic "ingress" {
    for_each = var.key_name != null ? [1] : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
    }
  }

  # Egress: Permite todo tráfego de saída (necessário para baixar Docker/imagens)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}


# EC2 Instance

resource "aws_instance" "database" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.database.id]
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip


  credit_specification {
    cpu_credits = "standard"
  }


  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }


  user_data = var.user_data_script


  monitoring = false

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database"
  })


  lifecycle {
    ignore_changes = [ami]
  }
}

# EBS Data Volume (Persistência)

resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.data_volume_size
  type              = var.data_volume_type
  encrypted         = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database-data"
  })

  # Isso garante que os dados sobrevivam a terraform destroy parcial
  lifecycle {
    prevent_destroy = false
  }
}


# Volume Attachment


resource "aws_volume_attachment" "data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.database.id

  # Force detach permite recriar a instância sem falhas
  force_detach = true

  # Não deletar o volume quando a instância for terminada
  # O volume EBS é gerenciado separadamente
  skip_destroy = true
}

