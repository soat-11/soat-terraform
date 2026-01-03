# Payment Database - MongoDB on EC2

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "mongo_db" {
  source = "../../../shared-modules/database-ec2"

  project_name     = "payment-mongo"
  vpc_id           = var.vpc_id
  subnet_id        = var.database_subnet_id
  ami_id           = data.aws_ami.amazon_linux_2.id
  instance_type    = "t3.small"
  data_volume_size = 20
  db_port          = 27017
  allowed_cidrs    = ["10.0.0.0/16"]

  user_data_script = templatefile("${path.module}/scripts/mongo-setup.sh", {
    mongo_user     = var.db_user
    mongo_password = var.db_password
  })
}
