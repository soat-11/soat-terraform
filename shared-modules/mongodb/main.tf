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

module "database" {
  source = "../database-ec2"

  project_name     = "${var.project_name}-mongo"
  vpc_id           = data.terraform_remote_state.cloud_base.outputs.vpc_id
  subnet_id        = data.terraform_remote_state.cloud_base.outputs.database_subnet_id
  ami_id           = data.aws_ami.amazon_linux_2.id
  instance_type    = var.instance_type
  data_volume_size = var.data_volume_size
  db_port          = 27017

  allowed_cidrs           = [data.terraform_remote_state.cloud_base.outputs.vpc_cidr_block]
  allowed_security_groups = try([data.terraform_remote_state.cloud_base.outputs.database_security_group_id], [])

  user_data_script = templatefile("${path.module}/scripts/mongo-setup.sh", {
    mongo_user     = var.db_user
    mongo_password = var.db_password
    mongo_version  = var.mongo_version
    database_name  = var.database_name != "" ? var.database_name : var.project_name
  })

  tags = var.tags
}
