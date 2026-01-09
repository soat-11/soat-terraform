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

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-database-sg"
  description = "Security Group for ${var.project_name} database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Database port access"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    cidr_blocks     = var.allowed_cidrs
    security_groups = var.allowed_security_groups
  }

  dynamic "ingress" {
    for_each = var.key_name != null ? [1] : []
    content {
      description     = "SSH access"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = var.allowed_cidrs
      security_groups = var.allowed_security_groups
    }
  }

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

  user_data  = var.user_data_script
  monitoring = false

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = var.data_volume_size
  type              = var.data_volume_type
  encrypted         = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-database-data"
  })

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_volume_attachment" "data" {
  device_name  = "/dev/xvdf"
  volume_id    = aws_ebs_volume.data.id
  instance_id  = aws_instance.database.id
  force_detach = true
  skip_destroy = true
}
