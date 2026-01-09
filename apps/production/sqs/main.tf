module "payment-confirmed-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "payment-confirmed-queue-dlq"
  queue_name        = "payment-confirmed-queue"
  max_receive_count = 3

  tags = {
    Name = "payment-confirmed-queue"
  }
}

module "production-started-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "production-started-queue-dlq"
  queue_name        = "production-started-queue"
  max_receive_count = 3

  tags = {
    Name = "production-started-queue"
  }
}

module "production-ready-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "production-ready-queue-dlq"
  queue_name        = "production-ready-queue"
  max_receive_count = 3

  tags = {
    Name = "production-ready-queue"
  }
}

module "production-withdrawn-queue" {
  source = "../../../shared-modules/sqs"

  dlq_name          = "production-withdrawn-queue-dlq"
  queue_name        = "production-withdrawn-queue"
  max_receive_count = 3

  tags = {
    Name = "production-withdrawn-queue"
  }
}

