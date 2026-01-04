# Payment Database - MongoDB on EC2

# -----------------------------------------------------------------------------
# Remote State - Cloud Base
# -----------------------------------------------------------------------------
# Obtém VPC e Subnet automaticamente do cloud-base
data "terraform_remote_state" "cloud_base" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "cloud-base/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -----------------------------------------------------------------------------
# MongoDB Instance
# -----------------------------------------------------------------------------
module "mongo_db" {
  source = "../../../shared-modules/database-ec2"

  project_name     = "payment-mongo"
  vpc_id           = data.terraform_remote_state.cloud_base.outputs.vpc_id
  subnet_id        = data.terraform_remote_state.cloud_base.outputs.database_subnet_id
  ami_id           = data.aws_ami.amazon_linux_2.id
  instance_type    = "t3.small"
  data_volume_size = 20
  db_port          = 27017

  # Segurança: aceita conexões apenas da VPC
  allowed_cidrs = [data.terraform_remote_state.cloud_base.outputs.vpc_cidr_block]

  user_data_script = templatefile("${path.module}/scripts/mongo-setup.sh", {
    mongo_user     = var.db_user
    mongo_password = var.db_password
  })
}
